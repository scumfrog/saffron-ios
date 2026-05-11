import Foundation

struct ExportService {
    static func exportJSON(recipes: [Recipe]) throws -> Data {
        let exportable = recipes.map { ExportableRecipe(from: $0) }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(exportable)
    }
}

private struct ExportableRecipe: Encodable {
    let id: String
    let title: String
    let sourceURL: String?
    let sourceLabel: String
    let sourceType: String
    let isFavorite: Bool
    let isArchived: Bool
    let timeMin: Int
    let servings: Int
    let difficulty: String
    let tags: [String]
    let ingredients: [ExportableIngredient]
    let steps: [String]
    let notes: String
    let addedAt: Date

    init(from r: Recipe) {
        id = r.id.uuidString
        title = r.title
        sourceURL = r.sourceURL
        sourceLabel = r.sourceLabel
        sourceType = r.sourceType.rawValue
        isFavorite = r.isFavorite
        isArchived = r.isArchived
        timeMin = r.timeMin
        servings = r.servings
        difficulty = r.difficulty
        tags = r.tags
        ingredients = r.ingredients.map(ExportableIngredient.init)
        steps = r.steps
        notes = r.notes
        addedAt = r.addedAt
    }
}

private struct ExportableIngredient: Encodable {
    let quantity: Double
    let unit: String
    let name: String

    init(from i: Ingredient) {
        quantity = i.quantity
        unit = i.unit
        name = i.name
    }
}
