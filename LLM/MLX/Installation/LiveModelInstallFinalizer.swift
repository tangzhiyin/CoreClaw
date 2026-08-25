import Foundation

enum LiveModelInstallFinalizer {
    static func validateRequiredFiles(
        requiredFiles: [String],
        assetID: String,
        at directory: URL
    ) throws {
        for requiredFile in requiredFiles {
            let url = directory.appendingPathComponent(requiredFile)
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
                throw DownloadFailure.invalidResponse("\(assetID) missing required file: \(requiredFile)")
            }
            if isDirectory.boolValue {
                guard directoryContainsNonEmptyFile(url) else {
                    throw DownloadFailure.invalidResponse("\(assetID) required directory is empty: \(requiredFile)")
                }
            } else {
                guard fileSize(url) > 0 else {
                    throw DownloadFailure.invalidResponse("\(assetID) required file is empty: \(requiredFile)")
                }
            }
        }
    }

    static func finalize(stagingDirectory: URL, finalDirectory: URL) throws {
        let parent = finalDirectory.deletingLastPathComponent()
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)

        let backupDirectory = parent.appendingPathComponent(
            ".\(finalDirectory.lastPathComponent).old-\(UUID().uuidString)",
            isDirectory: true
        )
        var hasBackup = false

        if fileManager.fileExists(atPath: finalDirectory.path) {
            try fileManager.moveItem(at: finalDirectory, to: backupDirectory)
            hasBackup = true
        }

        do {
            try fileManager.moveItem(at: stagingDirectory, to: finalDirectory)
            if hasBackup {
                try? fileManager.removeItem(at: backupDirectory)
            }
        } catch {
            if hasBackup, !fileManager.fileExists(atPath: finalDirectory.path) {
                try? fileManager.moveItem(at: backupDirectory, to: finalDirectory)
            }
            throw error
        }
    }

    private static func directoryContainsNonEmptyFile(_ directory: URL) -> Bool {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey]
        ) else {
            return false
        }
        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey]),
                  values.isRegularFile == true,
                  (values.fileSize ?? 0) > 0 else {
                continue
            }
            return true
        }
        return false
    }

    private static func fileSize(_ url: URL) -> Int64 {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path) else { return 0 }
        return (attrs[.size] as? Int64) ?? 0
    }
}
