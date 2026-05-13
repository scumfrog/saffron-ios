import SwiftUI

struct FavoriteCardView: View {
    let recipe: Recipe
    @Environment(AppTheme.self) private var theme

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Cover image
            Group {
                if let data = recipe.coverData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(theme.accent.gradient)
                }
            }
            .frame(width: 220, height: 280)
            .clipped()

            // Gradient overlay
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.45),
                    .init(color: .black.opacity(0.65), location: 1)
                ],
                startPoint: .top, endPoint: .bottom
            )

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.4), radius: 2)

                HStack(spacing: 10) {
                    if recipe.timeMin > 0 {
                        Label("\(recipe.timeMin) min", systemImage: "clock")
                    }
                    Label("\(recipe.servings)", systemImage: "person.2")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.9))
            }
            .padding(14)

            // Favorite badge
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(.black.opacity(0.35))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(12)
        }
        .frame(width: 220, height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .contentShape(Rectangle())
    }
}
