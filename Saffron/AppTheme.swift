import SwiftUI
import Observation

@Observable
final class AppTheme {
    var accentHex: String {
        didSet { UserDefaults.standard.set(accentHex, forKey: "accentHex") }
    }
    var colorSchemePreference: String {
        didSet { UserDefaults.standard.set(colorSchemePreference, forKey: "colorScheme") }
    }

    init() {
        accentHex = UserDefaults.standard.string(forKey: "accentHex") ?? "#C4623F"
        colorSchemePreference = UserDefaults.standard.string(forKey: "colorScheme") ?? "system"
    }

    var accent: Color {
        Color(hex: accentHex) ?? Color("Accent")
    }

    var preferredColorScheme: ColorScheme? {
        switch colorSchemePreference {
        case "light":  return .light
        case "dark":   return .dark
        default:       return nil
        }
    }

    static let accentOptions: [(name: String, hex: String)] = [
        ("Terracotta",  "#C4623F"),
        ("Sage",        "#6B8E5A"),
        ("Tomato",      "#B8453A"),
        ("Lavender",    "#8B6FB8"),
        ("Eucalyptus",  "#3F8B7A"),
        ("Ocean",       "#3A6FB8"),
    ]
}
