import SwiftUI

// MARK: - BrandMarkView
//
// 主聊天空白态使用低对比度 iPhone + AI 标记，作为背景而不是抢眼的 Logo。
struct BrandMarkView: View {
    var size: CGFloat = 90

    @State private var breathing = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.16, style: .continuous)
                .fill(Theme.bgElevated.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.16, style: .continuous)
                        .strokeBorder(Theme.textTertiary.opacity(0.34), lineWidth: 1.6)
                )

            VStack(spacing: size * 0.12) {
                Capsule()
                    .fill(Theme.textTertiary.opacity(0.28))
                    .frame(width: size * 0.24, height: 3)

                Image(systemName: "sparkles")
                    .font(.system(size: size * 0.23, weight: .light))
                    .foregroundStyle(Theme.accent.opacity(0.5))

                HStack(spacing: size * 0.08) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(Theme.textTertiary.opacity(0.3))
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .frame(width: size * 0.64, height: size)
        .opacity(0.72)
            .scaleEffect(breathing ? 1.008 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
                    breathing = true
                }
            }
    }
}

#Preview("BrandMark") {
    ZStack {
        Theme.bg
            .ignoresSafeArea()
        BrandMarkView()
    }
}
