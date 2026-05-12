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
            if (list.recipes ?? []).isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array((list.recipes ?? []).enumerated()), id: \.element.id) { index, recipe in
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
        let listColor = Color(hex: list.colorHex) ?? theme.accent
        return VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(listColor.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: list.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(listColor)
            }
            VStack(spacing: 8) {
                Text("No recipes yet")
                    .font(.headline)
                Text("Open any recipe, tap \u{201C}Add to list\u{201D}, and choose \u{201C}\(list.name)\u{201D}.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private func removeFromList(_ recipe: Recipe) {
        list.recipes?.removeAll { $0.id == recipe.id }
        try? context.save()
    }
}
