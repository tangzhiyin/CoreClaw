// swift-tools-version: 6.0
import PackageDescription

// CoreClaw Core Tests — XCTest unit tests for pure logic modules.
//
// Strategy: same symlink-based zero-drift approach as CoreClawCLI.
//   - Sources/CoreClawCore/*.swift are symlinks to main project source files
//   - Tests/CoreClawCoreTests/*.swift are real test files (committed)
//   - SPM treats the symlinked .swift files as part of the library target
//   - Test target imports CoreClawCore as a regular Swift module
//
// What's tested:
//   - GenerationTransaction state machine + cancel safety (plan §3.2)
//   - RuntimeSessionTransition transition whitelist (plan §3.2 / §4.2)
//   - PromptTokenEstimator CJK weighting (plan §九 Phase 3)
//   - ConversationMemoryPolicy history trimming (plan §3.2 ChatSessionController)
//
// Run: `cd Tests && swift test`
//
// Scope deliberately narrow: only files that compile standalone on macOS
// (no iOS frameworks). Stateful modules (AgentEngine, Coordinator) live
// in the iOS app target and are exercised by CoreClawCLI scenarios instead.

let package = Package(
    name: "CoreClawCoreTests",
    platforms: [.macOS(.v14)],
    targets: [
        .target(
            name: "CoreClawCore",
            path: "Sources/CoreClawCore"
        ),
        .testTarget(
            name: "CoreClawCoreTests",
            dependencies: ["CoreClawCore"],
            path: "Tests/CoreClawCoreTests"
        ),
    ]
)
