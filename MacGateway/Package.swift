// swift-tools-version: 6.0
import PackageDescription

// CoreClawGateway — macOS 图形客户端 (C)
//
// 主窗口 + 菜单栏, 跑 MacGateway (Bonjour 广播 + 多 provider 路由 + /pair 鉴权),
// 把本机 Ollama 等暴露给局域网内的 CoreClaw 手机。
//
// 0-drift symlink: Sources 里的 MacGateway/GatewayProviders/LANDiscovery 是软链,
// 指向主工程 LLM/Backends/Remote/ 的同一份 (跟 CoreClawCLI 一个套路)。这三个文件
// 只依赖 Foundation/Network, 不拖 LiteRT/MLX/llama, 所以这个 app 很轻。

let package = Package(
    name: "CoreClawGateway",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "CoreClawGateway",
            path: "Sources/CoreClawGateway",
            resources: [
                .copy("Resources/AppIcon.icns")
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "CoreClawGatewayTests",
            dependencies: ["CoreClawGateway"],
            path: "Tests/CoreClawGatewayTests",
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
