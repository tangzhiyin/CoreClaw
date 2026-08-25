import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - MLXLocalLLMService GPU + app lifecycle extension
//
// iPhone 禁止后台继续跑 Metal compute, 否则 jetsam 直接 kill。
// 这个 extension 监听 UIApplication 生命周期通知, 当 app 即将进入非活动状态时
// 立即取消当前的 generate/load task, 并把 foregroundGPUAllowed flag 置 false。
// ensureForegroundGPUExecution() 在关键路径前调用, 阻止任何后台提交。

extension MLXLocalLLMService {

    func ensureForegroundGPUExecution() async throws {
        #if canImport(UIKit)
        let isActive = await MainActor.run {
            UIApplication.shared.applicationState == .active
        }
        setForegroundGPUAllowed(isActive)
        guard isActive else {
            throw MLXError.gpuExecutionRequiresForeground
        }
        #endif
    }

    func configureLifecycleObservers() {
        #if canImport(UIKit)
        let center = NotificationCenter.default
        lifecycleObserverTokens = [
            center.addObserver(
                forName: UIApplication.willResignActiveNotification,
                object: nil,
                queue: nil
            ) { [weak self] _ in
                self?.handleApplicationLeavingForeground()
            },
            center.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil,
                queue: nil
            ) { [weak self] _ in
                self?.handleApplicationLeavingForeground()
            },
            center.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: nil
            ) { [weak self] _ in
                self?.setForegroundGPUAllowed(true)
            },
            center.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: nil
            ) { [weak self] _ in
                self?.setForegroundGPUAllowed(true)
            }
        ]

        Task { [weak self] in
            guard let self else { return }
            let isActive = await MainActor.run {
                UIApplication.shared.applicationState == .active
            }
            self.setForegroundGPUAllowed(isActive)
        }
        #endif
    }

    func handleApplicationLeavingForeground() {
        setForegroundGPUAllowed(false)
        cancelled = true
        currentGenerationTask?.cancel()
        currentLoadTask?.cancel()
    }

    func setForegroundGPUAllowed(_ allowed: Bool) {
        foregroundStateLock.lock()
        foregroundGPUAllowed = allowed
        foregroundStateLock.unlock()
    }

    func isForegroundGPUAllowed() -> Bool {
        foregroundStateLock.lock()
        let allowed = foregroundGPUAllowed
        foregroundStateLock.unlock()
        return allowed
    }
}
