import SwiftUI
import SwiftData

struct ListDetailView: View {
    let list: RecipeList
    @Environment(AppTheme.self) private var theme
    @Environment(\.modelContext) private var context
    @State private var selectedRecipe: Recipe?
    @State private var showDeleteConfirm = false
    @State private var recipeToRemove: Recipe?

    var body: some View {
        Group {
            if list.recipes.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(list.recipes.enumerated()), id: \.element.id) { index, recipe in
                            Button { selectedRecipe = recipe } label: {
                                RecipeRowView(recipe: recipe, isFirst: index == 0)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    removeFromList(recipe)
                                } label: {
                                    Label("Remove", systemImage: "minus.circle")
                                }
                            }
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 60)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipe: recipe)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife")
                .font(.system(size: 40))
                .foregroundStyle(.quaternary)
            Text("No recipes yet")
                .font(.headline)
            Text("Open a recipe and tap \"Add to list\".")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func removeFromList(_ recipe: Recipe) {
        list.recipes.removeAll { $0.id == recipe.id }
        try? context.save()
    }
}
