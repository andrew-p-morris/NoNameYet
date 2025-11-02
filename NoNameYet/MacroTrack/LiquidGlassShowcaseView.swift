import SwiftUI

struct LiquidGlassShowcaseView: View {
    var body: some View {
        ZStack {
            LiquidGlassBackground()

            VStack(spacing: 36) {
                VStack(spacing: 8) {
                    Text("Liquid Glass UI")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(LiquidGlassPalette.textPrimary)

                    Text("Frosted glass surfaces, crisp silver controls, and airy spacing for a premium health coach experience.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(LiquidGlassPalette.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                }

                LiquidGlassPane {
                    VStack(spacing: 24) {
                        GlassFieldRow(title: "Goal", subtitle: "Sculpted Strength", systemImage: "target")
                        Divider().blendMode(.overlay)
                        GlassFieldRow(title: "Daily Focus", subtitle: "Macros • Mobility • Recovery", systemImage: "waveform.path.ecg")
                        Divider().blendMode(.overlay)
                        GlassFieldRow(title: "Coach", subtitle: "Isla Kensington", systemImage: "person.crop.circle.badge.checkmark")
                    }
                    .padding(28)
                }

                HStack(spacing: 18) {
                    Button("View Coaching Plans") {}
                        .buttonStyle(LiquidGlassButtonStyle())

                    Button("Schedule Intro") {}
                        .buttonStyle(LiquidGlassButtonStyle(isEmphasized: false))
                }
            }
            .padding(.top, 80)
            .padding(.horizontal, 24)
        }
    }
}
private struct GlassFieldRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [LiquidGlassPalette.accentBright.opacity(0.45), LiquidGlassPalette.accentSoft.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle().stroke(LiquidGlassPalette.glassHighlight.opacity(0.6), lineWidth: 0.8)
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(LiquidGlassPalette.glyph)
                    .shadow(color: .white.opacity(0.6), radius: 1, y: 1)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LiquidGlassPalette.textSecondary.opacity(0.85))
                    .kerning(1.1)

                Text(subtitle)
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundStyle(LiquidGlassPalette.textPrimary)
                    .lineSpacing(2)
            }

            Spacer()
        }
    }
}

#Preview("Liquid Glass") {
    LiquidGlassShowcaseView()
        .preferredColorScheme(.light)
}

#Preview("Dark tint") {
    LiquidGlassShowcaseView()
        .background(Color.black)
        .preferredColorScheme(.dark)
}

