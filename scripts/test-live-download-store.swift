import Foundation

@main
struct LiveDownloadStoreTest {
    static func main() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("phoneclaw-live-download-store-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let staging = root.appendingPathComponent(".downloads/live-vad/staging", isDirectory: true)
        let final = root.appendingPathComponent("models/silero-vad-coreml", isDirectory: true)
        let requiredDirectory = "silero-vad-unified-256ms-v6.0.0.mlmodelc"
        let requiredFile = "\(requiredDirectory)/coremldata.bin"

        try FileManager.default.createDirectory(
            at: staging.appendingPathComponent(requiredDirectory, isDirectory: true),
            withIntermediateDirectories: true
        )
        try Data([1, 2, 3]).write(to: staging.appendingPathComponent(requiredFile))

        try LiveModelInstallFinalizer.validateRequiredFiles(
            requiredFiles: [requiredDirectory],
            assetID: "live-vad",
            at: staging
        )
        try LiveModelInstallFinalizer.finalize(stagingDirectory: staging, finalDirectory: final)

        precondition(
            FileManager.default.fileExists(atPath: final.appendingPathComponent(requiredFile).path),
            "Finalize should move staging files into the final model directory"
        )
        precondition(
            !FileManager.default.fileExists(atPath: staging.path),
            "Finalize should consume the staging directory"
        )

        let rollbackRoot = root.appendingPathComponent("rollback", isDirectory: true)
        let existingFinal = rollbackRoot.appendingPathComponent("models/asr", isDirectory: true)
        let missingStaging = rollbackRoot.appendingPathComponent(".downloads/live-asr/staging", isDirectory: true)
        try FileManager.default.createDirectory(at: existingFinal, withIntermediateDirectories: true)
        try Data([9]).write(to: existingFinal.appendingPathComponent("old.bin"))

        do {
            try LiveModelInstallFinalizer.finalize(
                stagingDirectory: missingStaging,
                finalDirectory: existingFinal
            )
            fatalError("Finalize should throw when staging is missing")
        } catch {
            precondition(
                FileManager.default.fileExists(atPath: existingFinal.appendingPathComponent("old.bin").path),
                "Finalize should roll back the previous final directory when replacement fails"
            )
        }

        let invalidStaging = root.appendingPathComponent("invalid/staging", isDirectory: true)
        try FileManager.default.createDirectory(at: invalidStaging, withIntermediateDirectories: true)
        try Data().write(to: invalidStaging.appendingPathComponent("empty.bin"))

        do {
            try LiveModelInstallFinalizer.validateRequiredFiles(
                requiredFiles: ["empty.bin"],
                assetID: "live-test",
                at: invalidStaging
            )
            fatalError("Required files must be non-empty")
        } catch DownloadFailure.invalidResponse(_) {
            // expected
        }

        print("LiveDownloadStore tests passed")
    }
}
