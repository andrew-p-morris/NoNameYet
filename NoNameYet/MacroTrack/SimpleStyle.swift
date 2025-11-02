import SwiftUI

enum SimplePalette {
    static let background = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let cardBackground = Color.white
    static let cardBorder = Color(red: 0.85, green: 0.85, blue: 0.88)
    static let textPrimary = Color(red: 0.17, green: 0.2, blue: 0.27)
    static let textSecondary = Color.black.opacity(0.55)
    static let accentBlue = Color(red: 0.2, green: 0.5, blue: 0.9)
    static let accentLight = Color(red: 0.85, green: 0.92, blue: 0.98)
}

struct SimpleCardPane<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(SimplePalette.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(SimplePalette.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
            )
    }
}

@ViewBuilder
func simpleBackground() -> some View {
    SimplePalette.background
        .ignoresSafeArea()
}

extension View {
    func simpleCardPadding() -> some View {
        self.padding(24)
    }
}

