import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID
    var title: String
    var coverData: Data?
    var sourceURL: String?
    var sourceLabel: String
    var sourceType: SourceType
    var isFavorite: Bool
    var isArchived: Bool
    var timeMin: Int
    var servings: Int
    var difficulty: String   // normalized: "easy" | "medium" | "hard"
    var tags: [String]
    var ingredients: [Ingredient]
    var steps: [String]
    var notes: String
    var addedAt: Date
    var lists: [RecipeList]

    init(
        title: String,
        coverData: Data? = nil,
        sourceURL: String? = nil,
        sourceLabel: String = "",
        sourceType: SourceType = .manual,
        isFavorite: Bool = false,
        isArchived: Bool = false,
        timeMin: Int = 0,
        servings: Int = 2,
        difficulty: String = "easy",
        tags: [String] = [],
        ingredients: [Ingredient] = [],
        steps: [String] = [],
        notes: String = ""
    ) {
        self.id = UUID()
        self.title = title
        self.coverData = coverData
        self.sourceURL = sourceURL
        self.sourceLabel = sourceLabel
        self.sourceType = sourceType
        self.isFavorite = isFavorite
        self.isArchived = isArchived
        self.timeMin = timeMin
        self.servings = servings
        self.difficulty = difficulty
        self.tags = tags
        self.ingredients = ingredients
        self.steps = steps
        self.notes = notes
        self.addedAt = Date()
        self.lists = []
    }

    var localizedDifficulty: String {
        switch difficulty.lowercased() {
        case "easy", "fácil", "facil":   return String(localized: "difficulty.easy")
        case "medium", "media":           return String(localized: "difficulty.medium")
        case "hard", "difícil", "dificil": return String(localized: "difficulty.hard")
        default:                          return difficulty
        }
    }
}
