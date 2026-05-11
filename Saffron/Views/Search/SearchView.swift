import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(AppTheme.self) private var theme
    @Query(sort: \Recipe.title) private var allRecipes: [Recipe]
    @State private var viewModel = SearchViewModel()
    @State private var selectedRecipe: Recipe?

    private var allTags: [String] {
        Array(Set(allRecipes.flatMap { $0.tags })).sorted()
    }

    private var filtered: [Recipe] {
        allRecipes.filter { viewModel.matches($0) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Search")
                        .font(.system(size: 34, weight: .bold))
                        .padding(.horizontal, 20)
                        .padding(.top, 6)

                    // Search bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Recipes, ingredients, tags", text: $viewModel.query)
                            .autocorrectionDisabled()
                        if !viewModel.query.isEmpty {
                            Button { viewModel.query = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)

                    // Tag chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(allTags, id: \.self) { tag in
                                let isActive = viewModel.activeTags.contains(tag)
                                Button { viewModel.toggleTag(tag) } label: {
                                    Text(LocalizedStringKey(tag))
                                        .font(.system(size: 14, weight: .medium))
                                        .tracking(-0.2)
                                        .foregroundStyle(isActive ? .white : .primary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(isActive ? theme.accent : Color(.tertiarySystemFill),
                                                    in: Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 4)
                    }
                }
                .padding(.bottom, 8)

                Divider()

                // Results
                if filtered.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundStyle(.quaternary)
                        Text("No results")
                            .font(.headline)
                        Text("Try a different keyword or tag.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                } else {
                    List(filtered) { recipe in
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
                                    HStack(spacing: 4) {
                                        ForEach(recipe.tags.prefix(3), id: \.self) { tag in
                                            Text("#\(tag)")
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}
