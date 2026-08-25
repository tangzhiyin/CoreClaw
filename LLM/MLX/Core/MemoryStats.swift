import Foundation
import Darwin

// MARK: - MemoryStats
//
// task_vm_info 包装。从 MLXLocalLLMService.swift L733-745 原样迁移,
// 额外提供 headroomMB 便捷访问。

enum MemoryStats {

    /// (footprint MB, jetsam limit MB) via task_info.
    static func footprintMB() -> (Double, Double) {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size)
        let kr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return (0, 0) }
        let footprint = Double(info.phys_footprint) / 1_048_576
        let limit = Double(info.limit_bytes_remaining) / 1_048_576 + footprint
        return (footprint, limit)
    }

    /// 当前可用内存 headroom (MB), 用于所有 budget 计算 (history 深度 / output token / 多模态 tier).
    static var headroomMB: Int {
        let (footprint, limit) = footprintMB()
        #if os(macOS)
        // macOS 没 jetsam, task_vm_info.limit_bytes_remaining 永远 0. 直接用 Mac
        // 物理内存 (60+ GB) 跟 iOS 真机不可比, RuntimeBudgets 看到天文数字会全走
        // 最高档. 模拟 iPhone jetsam 上限 (~6144 MB iPhone 15/16), 让 Mac 上
        // (jetsam_sim - footprint) 跟 iOS 真机的 headroom 数学一致 — E2B 加载后
        // 约 3GB 剩, E4B 约 1GB 剩, 各自命中跟真机一样的 history/output tier.
        // 这是平台测量对齐 (iOS 测真 jetsam, Mac 模拟同样的 ceiling), 不是 SKILL 规则.
        let simulatedJetsamMB = 6144
        return max(0, simulatedJetsamMB - Int(footprint))
        #else
        return max(0, Int(limit - footprint))
        #endif
    }
}
