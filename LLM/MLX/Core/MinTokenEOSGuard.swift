import Foundation
import MLX
import MLXLMCommon

// MARK: - Min Token EOS Guard
//
// 框架级 LogitProcessor: 强制生成至少 `minTokens` 个非 EOS token, 防止模型在
// R2 follow-up / 长 prompt 等场景下立即 emit EOS 造成 "Generated 0 tokens" 空回复.
//
// 真机 2026-04-17 E2B + F3 continuation prompt 场景下出现: prompt 2185 token,
// 模型首个 sample 直接是 `<end_of_turn>` → MLX 生成循环 `if stopTokenIds.contains(token) break`
// → 0 token 输出 → 用户看到 "(无回复)".
//
// 实现策略 (vLLM / TGI 通用做法): 在 logits 处理阶段, 若已生成 token < minTokens,
// 把 stop token 位置的 logit 值压到极小 (-1e30), 让 sampler 永远选不到 EOS.
// 达到 minTokens 后, processor 完全 no-op, 模型自然按训练分布决定何时停.
//
// 不是 SKILL 业务, 不绑定 model — 框架级通用机制.

public final class MinTokenEOSGuard: LogitProcessor {
    private let stopTokenIds: Set<Int>
    private let minTokens: Int
    private var samplesGenerated: Int = 0
    private var maskCache: MLXArray?

    public init(stopTokenIds: Set<Int>, minTokens: Int) {
        self.stopTokenIds = stopTokenIds
        self.minTokens = minTokens
    }

    public func prompt(_ prompt: MLXArray) {
        samplesGenerated = 0
    }

    public func process(logits: MLXArray) -> MLXArray {
        guard samplesGenerated < minTokens, !stopTokenIds.isEmpty else {
            return logits
        }
        // 直接在 logits 上把 stop token 位置压到极小 — 跟 RepetitionContext 同款 in-place 写入模式
        var modified = logits
        for id in stopTokenIds where id >= 0 {
            modified[0..., id] = MLXArray(Float(-1e30))
        }
        return modified
    }

    public func didSample(token: MLXArray) {
        samplesGenerated += 1
    }
}

// MARK: - Stop Token ID 收集
//
// 跟 MLXLMCommon.buildStopTokenIds 同款逻辑 (private 在 SDK 里没 public 出来,
// 我们这里独立计算). Gemma 系列模型的 end-of-turn token "<end_of_turn>" 也算 stop.

public func collectStopTokenIds(tokenizer: MLXLMCommon.Tokenizer) -> Set<Int> {
    var ids: Set<Int> = []
    // 1. Tokenizer 直接报的 EOS / unknown ID — MLX 生成循环遇到这两个都会 stop.
    if let id = tokenizer.eosTokenId { ids.insert(id) }
    if let id = tokenizer.unknownTokenId { ids.insert(id) }
    // 2. 字符串形式的常见 stop token — 不同模型支持不同, 都尝试一次, 拿到的就加.
    let candidates = [
        "<end_of_turn>",   // Gemma 系列 (跟 VLMModelFactory.extraEOSTokens 对齐)
        "<eos>",
        "<|endoftext|>",
        "<turn|>",         // PromptBuilder 用的关闭 marker
        "</s>"             // SentencePiece 风格
    ]
    for tok in candidates {
        if let id = tokenizer.convertTokenToId(tok) { ids.insert(id) }
    }
    return ids
}
