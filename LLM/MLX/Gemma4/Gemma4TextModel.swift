import MLX
import MLXFast
import MLXNN
import MLXLMCommon

// MARK: - Custom RMSNorm Variants

/// RMSNorm without learnable scale (with_scale=False)
class RMSNormNoScale: Module {
    let eps: Float

    init(eps: Float = 1e-6) {
        self.eps = eps
    }

    func callAsFunction(_ x: MLXArray) -> MLXArray {
        MLXFast.rmsNorm(x, weight: MLXArray.mlxNone, eps: eps)
    }
}

/// RMSNorm with scale_shift=0 (weight used directly, no +1 offset)
class RMSNormZeroShift: Module {
    let eps: Float
    var weight: MLXArray

    init(dimensions: Int, eps: Float = 1e-6) {
        self.eps = eps
        self.weight = MLXArray.ones([dimensions])
    }

    func callAsFunction(_ x: MLXArray) -> MLXArray {
        MLXFast.rmsNorm(x, weight: weight, eps: eps)
    }
}

/// ScaledLinear: linear layer with output scaling (for PLE)
class ScaledLinear: Module {
    var weight: MLXArray
    let scalar: Float

    init(inFeatures: Int, outFeatures: Int, scalar: Float) {
        self.weight = MLXArray.zeros([outFeatures, inFeatures])
        self.scalar = scalar
    }

    func callAsFunction(_ x: MLXArray) -> MLXArray {
        matmul(x, weight.transposed()) * scalar
    }
}

// MARK: - MLP

class Gemma4MLP: Module {
    @ModuleInfo(key: "gate_proj") var gateProj: Linear
    @ModuleInfo(key: "down_proj") var downProj: Linear
    @ModuleInfo(key: "up_proj") var upProj: Linear

    init(config: Gemma4TextConfiguration, layerIdx: Int) {
        let firstKvShared = config.firstKvSharedLayerIdx
        let isKvShared = layerIdx >= firstKvShared && firstKvShared > 0
        let useDoubleWide = config.useDoubleWideMlp && isKvShared
        let intermediateSize = config.intermediateSize * (useDoubleWide ? 2 : 1)

        self._gateProj.wrappedValue = Linear(config.hiddenSize, intermediateSize, bias: false)
        self._downProj.wrappedValue = Linear(intermediateSize, config.hiddenSize, bias: false)
        self._upProj.wrappedValue = Linear(config.hiddenSize, intermediateSize, bias: false)
    }

    func callAsFunction(_ x: MLXArray) -> MLXArray {
        downProj(geluApproximate(gateProj(x)) * upProj(x))
    }
}

// MARK: - Attention

class Gemma4Attention: Module {
    let config: Gemma4TextConfiguration
    let layerIdx: Int
    let layerType: String
    let isSliding: Bool
    let headDim: Int
    let nHeads: Int
    let nKvHeads: Int
    let scale: Float
    let isKvSharedLayer: Bool

    @ModuleInfo(key: "q_proj") var qProj: Linear
    @ModuleInfo(key: "k_proj") var kProj: Linear
    @ModuleInfo(key: "v_proj") var vProj: Linear
    @ModuleInfo(key: "o_proj") var oProj: Linear
    @ModuleInfo(key: "q_norm") var qNorm: RMSNorm
    @ModuleInfo(key: "k_norm") var kNorm: RMSNorm

    let vNorm: RMSNormNoScale
    let rope: Module

    init(config: Gemma4TextConfiguration, layerIdx: Int) {
        self.config = config
        self.layerIdx = layerIdx
        self.layerType = config.layerTypes[layerIdx]
        self.isSliding = layerType == "sliding_attention"

        // Full attention uses global_head_dim, sliding uses head_dim
        self.headDim = (layerType == "full_attention" && config.globalHeadDim > 0)
            ? config.globalHeadDim : config.headDim

        self.nHeads = config.numAttentionHeads
        self.nKvHeads = config.numKeyValueHeads
        self.scale = 1.0  // Gemma 4 uses scale=1.0

        let dim = config.hiddenSize
        self._qProj.wrappedValue = Linear(dim, nHeads * headDim, bias: false)
        self._kProj.wrappedValue = Linear(dim, nKvHeads * headDim, bias: false)
        self._vProj.wrappedValue = Linear(dim, nKvHeads * headDim, bias: false)
        self._oProj.wrappedValue = Linear(nHeads * headDim, dim, bias: false)

        self._qNorm.wrappedValue = RMSNorm(dimensions: headDim, eps: config.rmsNormEps)
        self._kNorm.wrappedValue = RMSNorm(dimensions: headDim, eps: config.rmsNormEps)
        self.vNorm = RMSNormNoScale(eps: config.rmsNormEps)

        // RoPE: different config per attention type
        let ropeKey = isSliding ? "sliding_attention" : "full_attention"
        let ropeConfig = config.ropeParameters?[ropeKey]
        self.rope = initializeGemma4Rope(
            dims: headDim,
            traditional: false,
            base: ropeConfig?.ropeTheta ?? 10000.0,
            ropeConfig: ropeConfig
        )

        // KV sharing
        let firstKvShared = config.firstKvSharedLayerIdx
        self.isKvSharedLayer = layerIdx >= firstKvShared && firstKvShared > 0
    }

    func callAsFunction(
        _ x: MLXArray,
        mask: MLXFast.ScaledDotProductAttentionMaskMode? = nil,
        cache: KVCache? = nil
    ) -> MLXArray {
        let (B, L, _) = (x.dim(0), x.dim(1), x.dim(2))

        var queries = qProj(x).reshaped(B, L, nHeads, headDim)
        queries = qNorm(queries)

        let offset = cache?.offset ?? 0
        queries = queries.transposed(0, 2, 1, 3)
        queries = applyRope(queries, offset: offset)

        // Shared-layer path: read K/V from the cache owned by a prior layer.
        // Quantized shared cache needs quantized SDPA; regular shared cache works
        // with the raw state arrays.
        if isKvSharedLayer, let cache = cache {
            if let qCache = cache as? QuantizedKVCache,
               let (quantKeys, quantValues) = qCache.getQuantizedState()
            {
                let effMask = resolveMask(mask: mask, length: qCache.offset, dtype: queries.dtype)
                let output = quantizedScaledDotProductAttention(
                    queries: queries,
                    quantizedKeys: quantKeys,
                    quantizedValues: quantValues,
                    scale: scale,
                    mask: effMask,
                    groupSize: qCache.groupSize,
                    bits: qCache.bits,
                    mode: qCache.mode
                )
                return oProj(output.transposed(0, 2, 1, 3).reshaped(B, L, -1))
            }
            let state = cache.state
            if state.count >= 2 {
                let sharedKeys = state[0]
                let sharedValues = state[1]
                let effMask = resolveMask(
                    mask: mask, length: sharedKeys.dim(-2), dtype: queries.dtype)
                let output = MLXFast.scaledDotProductAttention(
                    queries: queries,
                    keys: sharedKeys,
                    values: sharedValues,
                    scale: scale,
                    mask: effMask
                )
                return oProj(output.transposed(0, 2, 1, 3).reshaped(B, L, -1))
            }
            // state empty — source layer hasn't written yet; fall through and
            // behave like a non-shared layer (writes to cache). Normal model
            // layer order shouldn't reach this branch.
        }

        // Non-shared path: compute raw K/V, then dispatch by cache type.
        var keys = kProj(x).reshaped(B, L, nKvHeads, headDim)
        var values = vProj(x).reshaped(B, L, nKvHeads, headDim)
        keys = kNorm(keys)
        values = vNorm(values)
        values = values.transposed(0, 2, 1, 3)
        keys = keys.transposed(0, 2, 1, 3)
        keys = applyRope(keys, offset: offset)

        if let qCache = cache as? QuantizedKVCache {
            let (quantKeys, quantValues) = qCache.updateQuantized(keys: keys, values: values)
            let effMask = resolveMask(mask: mask, length: qCache.offset, dtype: queries.dtype)
            let output = quantizedScaledDotProductAttention(
                queries: queries,
                quantizedKeys: quantKeys,
                quantizedValues: quantValues,
                scale: scale,
                mask: effMask,
                groupSize: qCache.groupSize,
                bits: qCache.bits,
                mode: qCache.mode
            )
            return oProj(output.transposed(0, 2, 1, 3).reshaped(B, L, -1))
        }

        if let cache = cache {
            (keys, values) = cache.update(keys: keys, values: values)
        }

        let effMask = resolveMask(mask: mask, length: keys.dim(-2), dtype: queries.dtype)
        let output = MLXFast.scaledDotProductAttention(
            queries: queries,
            keys: keys,
            values: values,
            scale: scale,
            mask: effMask
        )
        .transposed(0, 2, 1, 3)
        .reshaped(B, L, -1)

        return oProj(output)
    }

    private func resolveMask(
        mask: MLXFast.ScaledDotProductAttentionMaskMode?,
        length: Int,
        dtype: DType
    ) -> MLXFast.ScaledDotProductAttentionMaskMode {
        let input = mask ?? .none
        guard case .array(let arr) = input else { return input }
        if arr.dim(-1) != length {
            let sliced = arr[.ellipsis, (arr.dim(-1) - length)...]
            return .array(sliced.asType(dtype))
        }
        return .array(arr.asType(dtype))
    }

    private func applyRope(_ x: MLXArray, offset: Int) -> MLXArray {
        if let proportionalRope = rope as? ProportionalRoPE {
            return proportionalRope(x, offset: offset)
        } else if let standardRope = rope as? RoPE {
            return standardRope(x, offset: offset)
        }
        return x
    }
}
