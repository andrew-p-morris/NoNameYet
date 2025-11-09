import SwiftUI

enum SimplePalette {
    // Retro pixelated video game colors
    static let background = Color(red: 0.29, green: 0.56, blue: 0.89) // Retro blue #4A90E2
    static let cardBackground = Color.white
    static let cardBorder = Color.black
    // Text colors - white for background, black for cards
    static let textPrimary = Color.white // For text on blue background
    static let textSecondary = Color.white.opacity(0.9) // For text on blue background
    static let cardTextPrimary = Color.black // For text on white cards
    static let cardTextSecondary = Color.black.opacity(0.7) // For text on white cards
    static let accentRed = Color(red: 1.0, green: 0.27, blue: 0.27) // #FF4444
    static let accentBlue = Color(red: 0.29, green: 0.56, blue: 0.89) // Same as background
    static let accentLight = Color.white.opacity(0.2)
    
    // Retro colors
    static let retroRed = Color(red: 1.0, green: 0.27, blue: 0.27)
    static let retroBlack = Color.black
    static let retroWhite = Color.white
    static let retroYellow = Color(red: 1.0, green: 0.85, blue: 0.0) // Yellow for today
    
    // Completion color (green)
    static let completionGreen = Color(red: 0.0, green: 0.8, blue: 0.0) // Green for completion
    
    // Water blue
    static let waterBlue = Color(red: 0.2, green: 0.6, blue: 1.0) // Blue for water elements
    
    // Retro font style
    static func retroFont(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

struct SimpleCardPane<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous) // Sharp corners for retro look
                    .fill(SimplePalette.cardBackground)
                    .overlay(
                        // Bold black border for pixelated look
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(SimplePalette.cardBorder, lineWidth: 3)
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 0, x: 4, y: 4) // Hard shadow for retro feel
            )
    }
}

@ViewBuilder
func simpleBackground() -> some View {
    // Solid retro blue background - no gradients for retro feel
    SimplePalette.background
        .ignoresSafeArea()
}

extension View {
    func simpleCardPadding() -> some View {
        self.padding(24)
    }
}

