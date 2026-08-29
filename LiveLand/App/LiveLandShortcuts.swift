import AppIntents
import Foundation

struct StartCoreClawLiveModeIntent: AppIntent {
    static var title: LocalizedStringResource = "Start CoreClaw LIVE Mode"
    static var description = IntentDescription("Open CoreClaw in the realtime LIVE voice mode.")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        LiveLaunchRequestStore.requestVoiceLaunch()
        return .result()
    }
}

struct OpenLiveLandIntent: AppIntent {
    static var title: LocalizedStringResource = "Open LiveLand"
    static var description = IntentDescription("Open CoreClaw and start LiveLand microphone listening in Dynamic Island.")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        LiveLaunchRequestStore.requestLiveLandLaunch()
        return .result()
    }
}

struct CoreClawAppShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .orange

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenLiveLandIntent(),
            phrases: [
                "Open \(.applicationName) LiveLand",
                "Launch \(.applicationName) LiveLand",
                "打开 \(.applicationName) LiveLand",
                "启动 \(.applicationName) LiveLand"
            ],
            shortTitle: "LiveLand",
            systemImageName: "waveform"
        )
        AppShortcut(
            intent: StartCoreClawLiveModeIntent(),
            phrases: [
                "Start \(.applicationName) LIVE Mode",
                "Open \(.applicationName) LIVE Mode",
                "开始 \(.applicationName) 实时语音",
                "打开 \(.applicationName) LIVE 模式",
                "和 \(.applicationName) 实时对话",
                "用 \(.applicationName) 开始 LIVE 模式"
            ],
            shortTitle: "LIVE Mode",
            systemImageName: "waveform"
        )
    }
}
