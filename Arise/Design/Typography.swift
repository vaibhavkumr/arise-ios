import SwiftUI

enum AFont {
    // System font with custom weights for the SL aesthetic
    static func title(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .black, design: .default)
    }

    static func heading(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }

    static func subheading(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }

    static func body(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }

    static func caption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }

    static func mono(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }

    // System-message style — bold, dramatic
    static func system(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
}

// MARK: - Modifiers

struct GlowText: ViewModifier {
    var color: Color
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius / 2)
            .shadow(color: color, radius: radius)
    }
}

extension View {
    func glowText(_ color: Color, radius: CGFloat = 8) -> some View {
        modifier(GlowText(color: color, radius: radius))
    }
}
