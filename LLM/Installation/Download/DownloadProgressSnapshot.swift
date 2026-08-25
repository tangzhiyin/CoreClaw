import Foundation

struct DownloadProgressSnapshot: Codable, Equatable, Sendable {
    let assetID: String
    let completedFileCount: Int
    let totalFileCount: Int
    let downloadedBytes: Int64
    let totalBytes: Int64?
    let bytesPerSecond: Double?
    let activeFilePath: String?
    let activeSourceLabel: String?
    let phase: DownloadProgressPhase
    let updatedAt: Date

    var byteFraction: Double? {
        guard let totalBytes, totalBytes > 0 else { return nil }
        return min(1, max(0, Double(downloadedBytes) / Double(totalBytes)))
    }

    var fileFraction: Double {
        guard totalFileCount > 0 else { return 0 }
        return min(1, max(0, Double(completedFileCount) / Double(totalFileCount)))
    }

    var combinedFraction: Double? {
        byteFraction ?? fileFraction
    }
}

enum DownloadProgressPhase: String, Codable, Equatable, Sendable {
    case idle
    case preflighting
    case downloading
    case validating
    case paused
    case complete
    case failed
}
