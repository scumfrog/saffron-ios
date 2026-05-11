import Foundation
import Observation

@Observable
final class SearchViewModel {
    var query: String = ""
    var activeTags: Set<String> = []

    func toggleTag(_ tag: String) {
        if activeTags.contains(tag) {
            activeTags.remove(tag)
        } else {
            activeTags.insert(tag)
        }
    }

    func matches(_ recipe: Recipe) -> Bool {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        let matchesQuery = q.isEmpty
            || recipe.title.lowercased().contains(q)
            || recipe.tags.contains { $0.lowercased().contains(q) }
            || recipe.ingredients.contains { $0.name.lowercased().contains(q) }
        let matchesTags = activeTags.isEmpty
            || activeTags.isSubset(of: Set(recipe.tags))
        return matchesQuery && matchesTags
    }
}
