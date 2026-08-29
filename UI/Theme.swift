import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - CoreClaw 设计系统(深灰,v3)
// 跨平台共享:macOS + iOS
//
// light/dark appearance 都保持深灰基调，依靠表面层级和文字明度区分。

struct Theme {
    // MARK: 背景
    static let bg = Color(light: "292B2F", dark: "16181B")
    static let bgElevated = Color(light: "34373C", dark: "202328")
    static let bgHover = Color(light: "41454B", dark: "2C3036")

    // MARK: 文字
    static let textPrimary = Color(light: "F1F2F3", dark: "F2F3F4")
    static let textSecondary = Color(light: "BEC1C5", dark: "B8BCC1")
    static let textTertiary = Color(light: "898E95", dark: "7D838B")
    static let assistantText = Color(light: "DADCDF", dark: "D4D7DA")

    // MARK: 强调色 (brand)
    static let accent = Color(light: "858D98", dark: "929BA7")
    static let accentSubtle = Color(light: "858D98", dark: "929BA7").opacity(0.22)
    static let accentMuted = Color(light: "747D88", dark: "808A96")
    static let accentGreen = Color(light: "71897A", dark: "7E9988")

    // MARK: 对话
    static let userBubble = Color(light: "50555D", dark: "383D44").opacity(0.72)
    static let userBubbleStroke = Color(light: "666D77", dark: "555C66").opacity(0.46)
    static let userText = Color(light: "ECEEF0", dark: "E7E9EB")
    static let quietAction = Color(light: "9DA2A9", dark: "8E949C").opacity(0.62)

    // MARK: 边框
    static let border = Color(light: "4B5058", dark: "373C43")
    static let borderSubtle = Color(light: "383C42", dark: "292D32")

    // MARK: 响应式间距
    #if os(macOS)
    static let chatPadH: CGFloat = 24
    static let chatSpacing: CGFloat = 28
    static let inputPadH: CGFloat = 20
    static let bubbleMinSpacer: CGFloat = 80
    static let aiMinSpacer: CGFloat = 40
    #else
    static let chatPadH: CGFloat = 16
    static let chatSpacing: CGFloat = 24
    static let inputPadH: CGFloat = 16
    static let bubbleMinSpacer: CGFloat = 60
    static let aiMinSpacer: CGFloat = 0
    #endif
}

// MARK: - Hex Color（跨平台）

extension Color {
    init(light: String, dark: String) {
        #if canImport(UIKit)
        self.init(UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
        #elseif canImport(AppKit)
        self.init(NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return NSColor(hex: isDark ? dark : light)
        })
        #else
        self.init(hex: light)
        #endif
    }

    init(hex: String) {
        let (a, r, g, b) = rgbaComponents(from: hex)
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

private func rgbaComponents(from hexString: String) -> (UInt64, UInt64, UInt64, UInt64) {
    let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    switch hex.count {
    case 6:
        return (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:
        return (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
        return (255, 0, 0, 0)
    }
}

#if canImport(UIKit)
private extension UIColor {
    convenience init(hex: String) {
        let (a, r, g, b) = rgbaComponents(from: hex)
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
#elseif canImport(AppKit)
private extension NSColor {
    convenience init(hex: String) {
        let (a, r, g, b) = rgbaComponents(from: hex)
        self.init(
            srgbRed: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
#endif
