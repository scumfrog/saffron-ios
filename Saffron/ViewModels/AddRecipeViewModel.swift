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
        guard url.scheme == "https" || url.scheme == "http" else { return false }
        return unsupportedPlatform == nil
    }

    /// Non-nil when the pasted URL belongs to a platform that doesn't expose
    /// recipe text (Instagram, TikTok, etc.). Returns the display name.
    var unsupportedPlatform: String? {
        guard let host = URL(string: urlText)?.host?.lowercased() else { return nil }
        return Self.unsupportedHosts[host]
    }

    private static let unsupportedHosts: [String: String] = [
        "instagram.com": "Instagram",
        "www.instagram.com": "Instagram",
        "tiktok.com": "TikTok",
        "www.tiktok.com": "TikTok",
        "vm.tiktok.com": "TikTok",
        "youtube.com": "YouTube",
        "www.youtube.com": "YouTube",
        "youtu.be": "YouTube",
        "facebook.com": "Facebook",
        "www.facebook.com": "Facebook",
        "threads.net": "Threads",
        "www.threads.net": "Threads",
        "x.com": "X",
        "twitter.com": "X",
    ]

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
            coverURL: extracted.coverURL,
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
