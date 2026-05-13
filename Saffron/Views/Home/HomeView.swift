import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(filter: #Predicate<Recipe> { $0.isFavorite && !$0.isArchived },
           sort: \Recipe.addedAt, order: .reverse)
    private var favorites: [Recipe]

    // Full list (no limit) — used only for the "N recipes saved" count in the header.
    @Query(filter: #Predicate<Recipe> { !$0.isArchived })
    private var allRecipes: [Recipe]

    // Limited to 15 at the database level — used for the Recent section.
    @Query({
        var d = FetchDescriptor<Recipe>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
        )
        d.fetchLimit = 15
        return d
    }())
    private var recentRecipes: [Recipe]

    @Environment(\.modelContext) private var context
    @State private var viewModel = HomeViewModel()
    @State private var selectedRecipe: Recipe?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    header
                    favoritesSection
                    recentsSection
                    Spacer().frame(height: 120)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .refreshable { await viewModel.refresh() }
            .navigationDestination(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Saffron")
                .font(.system(size: 34, weight: .bold))
                .tracking(0.37)
            Text("\(allRecipes.count) recipes saved")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 18)
    }

    @ViewBuilder
    private var favoritesSection: some View {
        if !favorites.isEmpty {
            SectionHeader(title: "Favorites", subtitle: "\(favorites.count) recipes")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(favorites) { recipe in
                        FavoriteCardView(recipe: recipe)
                            .onTapGesture { selectedRecipe = recipe }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 6)
                .padding(.bottom, 8)
            }
            .padding(.bottom, 14)
        }
    }

    private var recentsSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Recent", subtitle: "\(recentRecipes.count) recipes")
            VStack(spacing: 0) {
                ForEach(Array(recentRecipes.enumerated()), id: \.element.id) { index, recipe in
                    SwipeToDeleteRow(onDelete: { context.delete(recipe) }) {
                        RecipeRowView(recipe: recipe, isFirst: index == 0)
                            .onTapGesture { selectedRecipe = recipe }
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 16)
        }
    }
}
