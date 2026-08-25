import Foundation

enum DownloadFailure: Error, Equatable, Sendable {
    case invalidURL(String)
    case invalidResponse(String)
    case httpStatus(Int)
    case validatorMismatch(expected: String, actual: String, field: String)
    case insufficientDiskSpace(required: Int64, available: Int64)
    case manifestCorrupt(String)
    case fileSystem(String)
    case cancelled
}
