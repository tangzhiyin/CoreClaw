import Foundation
import XCTest

final class CrispSkillContractTests: XCTestCase {
    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func source(_ relativePath: String) throws -> String {
        try String(contentsOf: repoRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }

    func testCrispSkillIsBundledRegisteredAndLocalized() throws {
        let registry = try source("Skills/SkillRegistry.swift")
        let loader = try source("Skills/SkillLoader.swift")
        let processInput = try source("Agent/Engine/ProcessInput.swift")
        let project = try source("PhoneClaw.xcodeproj/project.pbxproj")
        let zh = try source("Skills/Library/crisp/SKILL.md")
        let en = try source("Skills/Library/crisp/SKILL.en.md")
        let ja = try source("Skills/Library/crisp/SKILL.ja.md")

        XCTAssertTrue(registry.contains("registerBuiltIn(id: \"crisp\")"))
        XCTAssertTrue(registry.contains("func defaultSkillId() -> String?"))
        XCTAssertTrue(registry.contains("$0.isEnabled && $0.metadata.isDefault"))
        XCTAssertTrue(loader.contains("let compactInstructions: String?"))
        XCTAssertTrue(loader.contains("let isDefault: Bool"))
        XCTAssertTrue(loader.contains("isDefault: frontmatter[\"default\"] as? Bool ?? false"))
        XCTAssertTrue(loader.contains("frontmatter[\"compact-instructions\"]"))
        XCTAssertTrue(processInput.contains("compactPrompt = instructions + \"\\n\" + compact"))
        XCTAssertTrue(project.contains("lastKnownFileType = folder; path = Library;"))
        XCTAssertTrue(project.contains("/* Library in Resources */"))

        for content in [zh, en, ja] {
            XCTAssertTrue(content.contains("name: Crisp"))
            XCTAssertTrue(content.contains("default: true"))
            XCTAssertTrue(content.contains("type: network"))
            XCTAssertTrue(content.contains("compact-instructions: >-"))
            XCTAssertTrue(content.contains("  - web-search"))
            XCTAssertTrue(content.contains("  - web-fetch"))
            XCTAssertTrue(content.contains("Microsoft Graph"))
            XCTAssertTrue(content.contains("Outlook"))
            XCTAssertTrue(content.contains("Exchange"))
            XCTAssertTrue(content.contains("Windows"))
            XCTAssertTrue(content.contains("macOS"))
            XCTAssertTrue(content.contains("iOS"))
            XCTAssertTrue(content.contains("Android"))
        }

        XCTAssertTrue(zh.contains("先给结论"))
        XCTAssertTrue(zh.contains("绝不假装已经登录、修改、发送、安装或修复"))
        XCTAssertTrue(en.contains("Lead with the conclusion"))
        XCTAssertTrue(ja.contains("最初に結論"))
    }

    func testCrispDefaultRoutingRunsAfterExplicitAndStickyRouting() throws {
        let processInput = try source("Agent/Engine/ProcessInput.swift")
        let lifecycle = try source("Agent/Engine/EngineLifecycle.swift")
        let toolChain = try source("Agent/Engine/ToolChain.swift")
        guard let stickyRoute = processInput.range(of: "let stickySkillId = recentActiveSkillId()"),
              let defaultRoute = processInput.range(of: "let defaultSkillId = skillRegistry.defaultSkillId()"),
              let exposedRoute = processInput.range(of: "self.lastTurnMatchedSkillIds = matchedSkillIdsForTurn") else {
            return XCTFail("Expected explicit sticky, default, and exposed routing stages")
        }

        XCTAssertLessThan(stickyRoute.lowerBound, defaultRoute.lowerBound)
        XCTAssertLessThan(defaultRoute.lowerBound, exposedRoute.lowerBound)
        XCTAssertTrue(processInput.contains("!forceImageFollowUpTextPrompt"))
        XCTAssertTrue(processInput.contains("source=default action=useSkill"))
        XCTAssertTrue(processInput.contains("defaultSkillIdForTurn = defaultSkillId"))
        XCTAssertTrue(processInput.contains("defaultSkillIdForTurn == id"))
        let defaultFallbackBlock = String(processInput[defaultRoute.lowerBound..<exposedRoute.lowerBound])
        XCTAssertFalse(defaultFallbackBlock.contains("allowPreloadedSkillFallbackForTurn = true"))
        XCTAssertTrue(lifecycle.contains("preferredSkillIds: [String] = []"))
        XCTAssertTrue(lifecycle.contains("definition.metadata.allowedTools.contains(name)"))
        XCTAssertTrue(toolChain.contains("preferredSkillIds: lastTurnMatchedSkillIds"))
    }
}
