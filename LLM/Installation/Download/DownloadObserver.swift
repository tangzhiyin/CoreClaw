import Foundation

protocol DownloadObserver: Sendable {
    func onProgress(_ snapshot: DownloadProgressSnapshot) async
    func onRetry(
        assetID: String,
        filePath: String,
        source: DownloadFile.Source,
        attempt: Int,
        error: DownloadFailure
    ) async
    func onSourceSwitch(
        assetID: String,
        filePath: String,
        from: DownloadFile.Source?,
        to: DownloadFile.Source,
        reason: DownloadFailure?
    ) async
    func onFailure(assetID: String, failure: DownloadFailure) async
}

extension DownloadObserver {
    func onProgress(_ snapshot: DownloadProgressSnapshot) async {}

    func onRetry(
        assetID: String,
        filePath: String,
        source: DownloadFile.Source,
        attempt: Int,
        error: DownloadFailure
    ) async {}

    func onSourceSwitch(
        assetID: String,
        filePath: String,
        from: DownloadFile.Source?,
        to: DownloadFile.Source,
        reason: DownloadFailure?
    ) async {}

    func onFailure(assetID: String, failure: DownloadFailure) async {}
}

struct NoopDownloadObserver: DownloadObserver {}
