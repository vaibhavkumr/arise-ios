import SwiftUI

enum AColor {
    // Backgrounds
    static let background    = Color(hex: "#0A0A0F")
    static let surface       = Color(hex: "#12121A")
    static let surfaceRaised = Color(hex: "#1A1A26")
    static let card          = Color(hex: "#16161F")

    // Brand
    static let electricBlue  = Color(hex: "#4FC3F7")
    static let deepBlue      = Color(hex: "#1565C0")
    static let royalPurple   = Color(hex: "#7C3AED")
    static let lightPurple   = Color(hex: "#A78BFA")
    static let shadowBlue    = Color(hex: "#0D47A1")

    // Rank colors
    static let rankE         = Color(hex: "#9E9E9E")
    static let rankD         = Color(hex: "#4CAF50")
    static let rankC         = Color(hex: "#2196F3")
    static let rankB         = Color(hex: "#9C27B0")
    static let rankA         = Color(hex: "#FF9800")
    static let rankS         = Color(hex: "#FFD700")
    static let rankNational  = Color(hex: "#FF4444")

    // Status
    static let success       = Color(hex: "#00E676")
    static let warning       = Color(hex: "#FFD740")
    static let danger        = Color(hex: "#FF1744")
    static let xpColor       = Color(hex: "#00BCD4")

    // Text
    static let textPrimary   = Color(hex: "#E8EAED")
    static let textSecondary = Color(hex: "#9AA0A6")
    static let textMuted     = Color(hex: "#5F6368")

    // Stat colors
    static let strColor      = Color(hex: "#FF5252")
    static let agiColor      = Color(hex: "#69F0AE")
    static let vitColor      = Color(hex: "#40C4FF")
    static let endColor      = Color(hex: "#FFD740")
    static let intColor      = Color(hex: "#E040FB")

    // Glows
    static let glowBlue      = Color(hex: "#4FC3F7").opacity(0.4)
    static let glowPurple    = Color(hex: "#7C3AED").opacity(0.4)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
