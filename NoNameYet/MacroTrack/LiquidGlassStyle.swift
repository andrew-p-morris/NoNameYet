import SwiftUI

enum LiquidGlassPalette {
    static let background = Color(red: 0.94, green: 0.95, blue: 0.97)
    static let glassTop = Color.white.opacity(0.65)
    static let glassBottom = Color.white.opacity(0.12)
    static let glassBorder = Color.white.opacity(0.45)
    static let glassHighlight = Color.white.opacity(0.9)

    static let accentSoft = Color(red: 0.74, green: 0.86, blue: 0.96)
    static let accentBright = Color(red: 0.54, green: 0.78, blue: 0.96)

    static let silverStart = Color(red: 0.82, green: 0.83, blue: 0.86)
    static let silverMid = Color(red: 0.72, green: 0.73, blue: 0.76)
    static let silverEnd = Color(red: 0.55, green: 0.56, blue: 0.6)

    static let glyph = Color(red: 0.5, green: 0.55, blue: 0.63)
    static let textPrimary = Color(red: 0.17, green: 0.2, blue: 0.27)
    static let textSecondary = Color.black.opacity(0.55)
}

struct LiquidGlassBackground: View {
    var body: some View {
        ZStack {
            LiquidGlassPalette.background
            Circle()
                .fill(LiquidGlassPalette.accentSoft.opacity(0.28))
                .blur(radius: 120)
                .frame(width: 380, height: 380)
                .offset(x: -140, y: -220)

            Circle()
                .fill(LiquidGlassPalette.accentBright.opacity(0.22))
                .blur(radius: 140)
                .frame(width: 320, height: 320)
                .offset(x: 180, y: -160)

            Circle()
                .fill(LiquidGlassPalette.accentSoft.opacity(0.18))
                .blur(radius: 150)
                .frame(width: 420, height: 420)
                .offset(x: 60, y: 260)
        }
        .ignoresSafeArea()
    }
}

struct LiquidGlassPane<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        RoundedRectangle(cornerRadius: 40, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [LiquidGlassPalette.glassTop, LiquidGlassPalette.glassBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .strokeBorder(LiquidGlassPalette.glassBorder, lineWidth: 1.2)
                    .shadow(color: LiquidGlassPalette.glassHighlight.opacity(0.2), radius: 16, y: 6)
            )
            .overlay(content)
            .overlay(
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [LiquidGlassPalette.glassHighlight, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.8
                    )
                    .blendMode(.screen)
            )
            .shadow(color: LiquidGlassPalette.glassHighlight.opacity(0.28), radius: 40, y: 26)
            .shadow(color: LiquidGlassPalette.glassHighlight.opacity(0.2), radius: 12, x: -12, y: -8)
    }
}

struct LiquidGlassButtonStyle: ButtonStyle {
    var isEmphasized: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .tracking(0.5)
            .textCase(.uppercase)
            .foregroundStyle(isEmphasized ? LiquidGlassPalette.textPrimary : LiquidGlassPalette.textPrimary.opacity(0.8))
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(buttonBackground(configuration: configuration))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [LiquidGlassPalette.glassHighlight.opacity(0.9), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                    .blendMode(.overlay)
            )
            .shadow(color: .black.opacity(isEmphasized ? 0.18 : 0.12), radius: isEmphasized ? 14 : 10, y: isEmphasized ? 12 : 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.74, blendDuration: 0.15), value: configuration.isPressed)
    }

    @ViewBuilder
    private func buttonBackground(configuration: Configuration) -> some View {
        let baseGradient = LinearGradient(
            colors: configuration.isPressed
                ? [LiquidGlassPalette.silverMid, LiquidGlassPalette.silverEnd]
                : [LiquidGlassPalette.silverStart, LiquidGlassPalette.silverEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(baseGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [LiquidGlassPalette.glassHighlight.opacity(configuration.isPressed ? 0.35 : 0.65), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }
}

@ViewBuilder
func liquidGlassBackground() -> some View {
    LiquidGlassBackground()
}

extension View {
    func liquidGlassPanePadding() -> some View {
        self
            .padding(28)
    }
}

