import SwiftUI
import SwiftData

struct ArchivedRecipesView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Recipe> { $0.isArchived },
           sort: \Recipe.addedAt, order: .reverse)
    private var archived: [Recipe]

    @State private var selectedRecipe: Recipe?

    var body: some View {
        Group {
            if archived.isEmpty {
                ContentUnavailableView(
                    "No archived recipes",
                    systemImage: "archivebox",
                    description: Text("Recipes you archive will appear here.")
                )
            } else {
                List(archived) { recipe in
                    Button { selectedRecipe = recipe } label: {
                        HStack(spacing: 12) {
                            Group {
                                if let data = recipe.coverData, let ui = UIImage(data: data) {
                                    Image(uiImage: ui)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    theme.accent.opacity(0.15)
                                }
                            }
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(recipe.title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .tracking(-0.2)
                                    .foregroundStyle(.primary)
                                Text(recipe.addedAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            recipe.isArchived = false
                            try? context.save()
                        } label: {
                            Label("Unarchive", systemImage: "arrow.uturn.up")
                        }
                        .tint(.green)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            context.delete(recipe)
                            try? context.save()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Archived")
        .navigationBarTitleDisplayMode(.inline)
        .tint(theme.accent)
        .navigationDestination(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipe: recipe)
        }
    }
}
