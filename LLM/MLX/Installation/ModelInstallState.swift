import Foundation

// MARK: - Install State

public enum ModelInstallState: Equatable, Sendable {
    case notInstalled
    case checkingSource
    case downloading(completedFiles: Int, totalFiles: Int, currentFile: String)
    case downloaded
    case bundled
    case failed(String)
}

public struct ModelDownloadMetrics: Equatable, Sendable {
    public let bytesReceived: Int64
    public let totalBytes: Int64?
    public let bytesPerSecond: Double?
    public let sourceLabel: String?
}

// MARK: - Errors

enum MLXError: LocalizedError {
    case modelNotLoaded
    case modelDirectoryMissing(String)
    case gpuExecutionRequiresForeground
    case multimodalMemoryRisk(model: String, headroomMB: Int, recommendation: String)
    case modelBusy

    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "MLX model not loaded. Call load() first."
        case .modelDirectoryMissing(let modelName):
            return "\(modelName) 模型文件不存在，请先在配置页下载或重新安装。"
        case .gpuExecutionRequiresForeground:
            return "应用进入后台时，iPhone 不允许继续提交 GPU 推理任务。"
        case .multimodalMemoryRisk(let model, let headroomMB, let recommendation):
            return "\(model) 当前剩余内存仅约 \(headroomMB) MB，继续处理图片/音频很可能被系统直接杀掉。\(recommendation)"
        case .modelBusy:
            return "模型正忙，无法切换音频能力。请稍后重试。"
        }
    }
}

enum DownloadError: LocalizedError {
    case invalidURL(String)
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let file):
            return "无法构造下载链接：\(file)"
        case .invalidResponse:
            return "下载源响应无效"
        case .httpStatus(let statusCode):
            switch statusCode {
            case 401, 403:
                return "下载源拒绝访问（\(statusCode)）"
            case 404:
                return "模型文件不存在（404）"
            case 429:
                return "下载过于频繁，请稍后重试（429）"
            default:
                return "下载失败，HTTP \(statusCode)"
            }
        }
    }
}
