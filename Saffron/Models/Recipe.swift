import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID = UUID()
    var title: String = ""
    var coverData: Data?
    var coverURL: String?   // Original image URL; persisted so re-download never needs AI
    var sourceURL: String?
    var sourceLabel: String = ""
    var sourceType: SourceType = SourceType.manual
    var isFavorite: Bool = false
    var isArchived: Bool = false
    var timeMin: Int = 0
    var servings: Int = 2
    var difficulty: String = "easy"
    var tags: [String] = []
    var ingredients: [Ingredient] = []
    var steps: [String] = []
    var notes: String = ""
    var addedAt: Date = Date.now
    var lists: [RecipeList]?

    init(
        title: String,
        coverData: Data? = nil,
        coverURL: String? = nil,
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
        self.coverURL = coverURL
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

    var localizedDifficulty: String { Difficulty.from(difficulty).localizedName }
}

// MARK: - Difficulty

/// Type-safe wrapper for the `difficulty` string stored in the model.
/// Kept separate from the model field (which stays `String`) to avoid a CloudKit migration.
enum Difficulty: String, CaseIterable {
    case easy, medium, hard

    static func from(_ raw: String) -> Difficulty {
        switch raw.lowercased() {
        case "easy",   "fácil",  "facil":           return .easy
        case "medium", "media",  "medio":            return .medium
        case "hard",   "difícil","dificil", "alta":  return .hard
        default:                                     return .easy
        }
    }

    var localizedName: String {
        switch self {
        case .easy:   return String(localized: "difficulty.easy")
        case .medium: return String(localized: "difficulty.medium")
        case .hard:   return String(localized: "difficulty.hard")
        }
    }
}
