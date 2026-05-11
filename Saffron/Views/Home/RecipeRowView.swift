import SwiftUI
import SwiftData

struct RecipeRowView: View {
    let recipe: Recipe
    let isFirst: Bool
    @Environment(AppTheme.self) private var theme
    @Environment(\.modelContext) private var context

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            Group {
                if let data = recipe.coverData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(theme.accent.opacity(0.15))
                        .overlay(
                            Image(systemName: "fork.knife")
                                .foregroundStyle(theme.accent.opacity(0.5))
                        )
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.system(size: 15, weight: .semibold))
                    .tracking(-0.2)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Label("\(recipe.timeMin) min", systemImage: "clock")
                    Text("·")
                    Label("\(recipe.servings)", systemImage: "person.2")
                    Text("·")
                    Image(systemName: recipe.sourceType.systemImage)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            if recipe.isFavorite {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(theme.accent)
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .overlay(alignment: .top) {
            if !isFirst {
                Divider()
                    .padding(.leading, 82)
            }
        }
        .contentShape(Rectangle())
    }
}
