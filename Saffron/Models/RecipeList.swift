import Foundation
import SwiftData
import SwiftUI

@Model
final class RecipeList {
    var id: UUID
    var name: String
    var icon: String       // emoji
    var colorHex: String
    var createdAt: Date
    @Relationship(deleteRule: .nullify, inverse: \Recipe.lists)
    var recipes: [Recipe]

    init(name: String, icon: String = "fork.knife", colorHex: String = "#8E8E93") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.createdAt = Date()
        self.recipes = []
    }

    var color: Color {
        Color(hex: colorHex) ?? .gray
    }
}

// MARK: - Color hex init

extension Color {
    init?(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard h.count == 6, let value = UInt64(h, radix: 16) else { return nil }
        self.init(
            red:   Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8)  & 0xFF) / 255,
            blue:  Double( value        & 0xFF) / 255
        )
    }
}
