import Foundation

struct DownloadAsset: Equatable, Identifiable, Sendable {
    let id: String
    let displayName: String
    let destinationDirectory: URL
    let files: [DownloadFile]
    let preservesWorkspaceOnCompletion: Bool

    init(
        id: String,
        displayName: String,
        destinationDirectory: URL,
        files: [DownloadFile],
        preservesWorkspaceOnCompletion: Bool = false
    ) {
        precondition(Self.isValidID(id), "DownloadAsset.id may only contain letters, digits, '.', '_', or '-'")
        self.id = id
        self.displayName = displayName
        self.destinationDirectory = destinationDirectory
        self.files = files
        self.preservesWorkspaceOnCompletion = preservesWorkspaceOnCompletion
    }

    static func isValidID(_ id: String) -> Bool {
        guard !id.isEmpty else { return false }
        return id.range(of: #"^[A-Za-z0-9._-]+$"#, options: .regularExpression) != nil
    }
}

struct DownloadFile: Codable, Equatable, Identifiable, Sendable {
    struct Source: Codable, Equatable, Sendable {
        let label: String
        let url: URL
        /// Lower values are tried first. `0` is the default highest priority.
        let priority: Int

        init(label: String, url: URL, priority: Int = 0) {
            self.label = label
            self.url = url
            self.priority = priority
        }
    }

    let relativePath: String
    let expectedSize: Int64?
    let expectedSHA256: String?
    let sources: [Source]

    var id: String { relativePath }

    init(
        relativePath: String,
        expectedSize: Int64? = nil,
        expectedSHA256: String? = nil,
        sources: [Source]
    ) {
        self.relativePath = relativePath
        self.expectedSize = expectedSize
        self.expectedSHA256 = expectedSHA256
        self.sources = sources
    }
}

struct DownloadManifest: Codable, Equatable, Sendable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let assetID: String
    let createdAt: Date
    let updatedAt: Date
    let files: [DownloadManifestFile]

    init(
        schemaVersion: Int = DownloadManifest.currentSchemaVersion,
        assetID: String,
        createdAt: Date,
        updatedAt: Date,
        files: [DownloadManifestFile]
    ) {
        self.schemaVersion = schemaVersion
        self.assetID = assetID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.files = files
    }
}

struct DownloadManifestFile: Codable, Equatable, Sendable {
    let relativePath: String
    let state: DownloadManifestFileState
    let downloadedBytes: Int64
    let expectedBytes: Int64?
    let selectedSourceLabel: String?
    let metadata: DownloadFileMetadata?

    init(
        relativePath: String,
        state: DownloadManifestFileState,
        downloadedBytes: Int64,
        expectedBytes: Int64? = nil,
        selectedSourceLabel: String? = nil,
        metadata: DownloadFileMetadata? = nil
    ) {
        self.relativePath = relativePath
        self.state = state
        self.downloadedBytes = downloadedBytes
        self.expectedBytes = expectedBytes
        self.selectedSourceLabel = selectedSourceLabel
        self.metadata = metadata
    }
}

enum DownloadManifestFileState: String, Codable, Equatable, Sendable {
    case pending
    case downloading
    case paused
    case complete
    case failed
}

struct DownloadFileMetadata: Codable, Equatable, Sendable {
    let sourceURL: URL?
    let sourceHost: String?
    let etag: String?
    let contentLength: Int64?
    let lastModified: String?
    let checksumSHA256: String?
    let updatedAt: Date?

    init(
        sourceURL: URL? = nil,
        sourceHost: String? = nil,
        etag: String? = nil,
        contentLength: Int64? = nil,
        lastModified: String? = nil,
        checksumSHA256: String? = nil,
        updatedAt: Date? = nil
    ) {
        self.sourceURL = sourceURL
        self.sourceHost = sourceHost
        self.etag = etag
        self.contentLength = contentLength
        self.lastModified = lastModified
        self.checksumSHA256 = checksumSHA256
        self.updatedAt = updatedAt
    }
}

struct DownloadResumeState: Equatable, Sendable {
    let downloadedBytes: Int64
    let totalBytes: Int64?
    let resumableFileCount: Int

    init(downloadedBytes: Int64, totalBytes: Int64?, resumableFileCount: Int) {
        self.downloadedBytes = downloadedBytes
        self.totalBytes = totalBytes
        self.resumableFileCount = resumableFileCount
    }
}
