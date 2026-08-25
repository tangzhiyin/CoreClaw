import SwiftUI

// MARK: - 共享 UI 组件

struct UserBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 18, sr: CGFloat = 4
        return Path { p in
            p.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
            p.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                     tangent2End: CGPoint(x: rect.maxX, y: rect.minY + r), radius: r)
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - sr))
            p.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
                     tangent2End: CGPoint(x: rect.maxX - sr, y: rect.maxY), radius: sr)
            p.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
            p.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
                     tangent2End: CGPoint(x: rect.minX, y: rect.maxY - r), radius: r)
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
            p.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                     tangent2End: CGPoint(x: rect.minX + r, y: rect.minY), radius: r)
        }
    }
}

struct SpinnerIcon: View {
    @State private var rotating = false
    var body: some View {
        Image(systemName: "asterisk")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Theme.textTertiary)
            .rotationEffect(.degrees(rotating ? 360 : 0))
            .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: rotating)
            .onAppear { rotating = true }
    }
}

