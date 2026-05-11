import Foundation
import Observation

enum ExtractionStage {
    case input
    case extracting
    case preview(ExtractedRecipe)
    case failed(String)
}

@Observable
final class AddRecipeViewModel {
    var urlText: String = ""
    var stage: ExtractionStage = .input

    // Editable fields in preview stage
    var editedTitle: String = ""
    var editedIngredients: [ExtractedIngredient] = []
    var editedSteps: [String] = []

    var canExtract: Bool {
        guard let url = URL(string: urlText) else { return false }
        return url.scheme == "https" || url.scheme == "http"
    }

    func extract() async {
        guard let url = URL(string: urlText) else { return }
        stage = .extracting
        do {
            let result = try await ExtractionService.shared.extract(url: url)
            editedTitle = result.title
            editedIngredients = result.ingredients
            editedSteps = result.steps
            stage = .preview(result)
        } catch {
            stage = .failed(error.localizedDescription)
        }
    }

    func buildRecipe(coverData: Data?) -> Recipe {
        guard case .preview(let extracted) = stage else {
            preconditionFailure("buildRecipe called outside preview stage")
        }
        return Recipe(
            title: editedTitle,
            coverData: coverData,
            sourceURL: urlText,
            sourceLabel: extracted.sourceLabel,
            sourceType: sourceType(for: urlText),
            timeMin: extracted.timeMin ?? 0,
            servings: extracted.servings ?? 2,
            difficulty: extracted.difficulty ?? "easy",
            tags: extracted.tags,
            ingredients: editedIngredients.map {
                Ingredient(quantity: $0.quantity, unit: $0.unit, name: $0.name)
            },
            steps: editedSteps
        )
    }

    func reset() {
        urlText = ""
        stage = .input
        editedTitle = ""
        editedIngredients = []
        editedSteps = []
    }

    private func sourceType(for urlString: String) -> SourceType {
        if urlString.contains("instagram.com") { return .instagram }
        return .blog
    }
}
