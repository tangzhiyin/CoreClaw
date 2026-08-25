import Foundation

// MARK: - Model Installer Protocol
//
// 模型资产的下载、安装、路径管理。独立于推理。
//
// 设计:
//   - 不 import 任何推理框架
//   - 下载进度通过 @Observable 属性暴露给 UI
//   - 路径解析支持 bundle / sandbox / symlink

/// 下载进度
public struct DownloadProgress: Sendable, Equatable {
    public let bytesReceived: Int64
    public let totalBytes: Int64?
    public let bytesPerSecond: Double?
    public let currentFile: String?

    public init(
        bytesReceived: Int64 = 0,
        totalBytes: Int64? = nil,
        bytesPerSecond: Double? = nil,
        currentFile: String? = nil
    ) {
        self.bytesReceived = bytesReceived
        self.totalBytes = totalBytes
        self.bytesPerSecond = bytesPerSecond
        self.currentFile = currentFile
    }

    /// 0.0 ~ 1.0，totalBytes 未知时返回 nil
    public var fractionCompleted: Double? {
        guard let total = totalBytes, total > 0 else { return nil }
        return Double(bytesReceived) / Double(total)
    }
}

// 状态字典 (installStates / downloadProgress / 内部 resumable / activeTasks) 的读写
// 必须收敛到 MainActor。背景: 这些字段是 SwiftUI @Observable 状态源, UI body 在主
// 线程同步读, 安装协程在后台写 — 不隔离会触发 Dictionary backing storage 的并发
// 破坏 (TestFlight 1.4.0(27) 崩溃; arm64e 上表现为 PAC 失败的 EXC_BAD_ACCESS)。
//
// 例外: `artifactPath` 是纯文件系统查询, backends (LiteRTBackend / MiniCPMVBackend)
// 在 nonisolated async load 路径里同步调它, 不能让它跳 main, 因此保持 nonisolated。
public protocol ModelInstaller: AnyObject {

    /// 下载并安装模型
    @MainActor
    func install(model: ModelDescriptor) async throws

    /// 删除已安装的模型
    @MainActor
    func remove(model: ModelDescriptor) throws

    /// 取消正在进行的下载
    @MainActor
    func cancelInstall(modelID: String)

    /// 查询安装状态
    @MainActor
    func installState(for modelID: String) -> ModelInstallState

    /// 是否存在可继续下载的 partial/manifest 状态
    @MainActor
    func hasResumableDownload(for modelID: String) -> Bool

    /// 是否存在这个模型的本地文件或断点残留
    @MainActor
    func hasLocalArtifacts(for model: ModelDescriptor) -> Bool

    /// 获取模型文件的本地路径 (nil = 未安装)。
    /// nonisolated: backends 在 load 路径里跨线程同步调, 实现只能做无锁文件系统查询。
    func artifactPath(for model: ModelDescriptor) -> URL?

    /// 刷新安装状态 (检查磁盘)
    @MainActor
    func refreshInstallStates()

    /// 各模型的下载进度 (可观察)
    @MainActor
    var downloadProgress: [String: DownloadProgress] { get }

    /// 各模型的安装状态 (可观察)
    @MainActor
    var installStates: [String: ModelInstallState] { get }
}

public extension ModelInstaller {
    @MainActor
    func hasResumableDownload(for modelID: String) -> Bool {
        false
    }

    @MainActor
    func hasLocalArtifacts(for model: ModelDescriptor) -> Bool {
        artifactPath(for: model) != nil
    }
}
