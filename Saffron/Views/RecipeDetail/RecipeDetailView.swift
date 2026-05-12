import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(AppTheme.self) private var theme
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var currentTab: DetailTab = .ingredients
    @State private var servings: Int
    @State private var checkedIngredients: Set<Int> = []
    @State private var isFavorite: Bool
    @State private var showCookMode = false
    @State private var showAddToList = false
    @State private var showDeleteConfirm = false
    @State private var showArchiveConfirm = false
    @State private var imageFetchFailed = false
    @State private var saveError: String?
    @State private var showAllIngredients = false

    enum DetailTab: String, CaseIterable {
        case ingredients = "Ingredients"
        case steps = "Steps"
        case notes = "Notes"
    }

    init(recipe: Recipe) {
        self.recipe = recipe
        _servings = State(initialValue: recipe.servings)
        _isFavorite = State(initialValue: recipe.isFavorite)
    }

    private var ratio: Double {
        Double(servings) / Double(max(recipe.servings, 1))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroImage
                bodyCard
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems }
        .fullScreenCover(isPresented: $showCookMode) {
            CookModeView(recipe: recipe)
        }
        .sheet(isPresented: $showAddToList) {
            AddToListView(recipe: recipe)
        }
        .confirmationDialog("Delete recipe?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                context.delete(recipe)
                do {
                    try context.save()
                    dismiss()
                } catch {
                    saveError = error.localizedDescription
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
        .confirmationDialog(
            recipe.isArchived ? "Unarchive recipe?" : "Archive recipe?",
            isPresented: $showArchiveConfirm, titleVisibility: .visible
        ) {
            Button(recipe.isArchived ? "Unarchive" : "Archive") {
                recipe.isArchived.toggle()
                do {
                    try context.save()
                    if !recipe.isArchived { dismiss() }
                } catch {
                    recipe.isArchived.toggle() // revert
                    saveError = error.localizedDescription
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(recipe.isArchived
                 ? "This recipe will appear in your main library again."
                 : "Archived recipes are hidden from the main library.")
        }
        .task(id: recipe.id) {
            // Only retry if image is missing and we have a stored cover URL.
            // Uses ImageCacheService directly — never needs a full AI re-extraction.
            guard recipe.coverData == nil, recipe.coverURL != nil else { return }
            guard let data = await ImageCacheService.shared.fetchImageData(from: recipe.coverURL) else {
                imageFetchFailed = true
                return
            }
            imageFetchFailed = false
            recipe.coverData = data
            try? context.save()
        }
        .alert("Save Error", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK") { saveError = nil }
        } message: {
            Text(saveError ?? "")
        }
    }

    // MARK: - Hero

    private var heroImage: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .named("scroll")).minY
            ZStack {
                if let data = recipe.coverData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geo.size.width,
                            height: max(320, 320 + minY)
                        )
                        .offset(y: minY > 0 ? -minY * 0.5 : 0)
                        .clipped()
                } else {
                    theme.accent
                        .frame(height: max(320, 320 + minY))
                    VStack(spacing: 12) {
                        Image(systemName: imageFetchFailed ? "photo.badge.exclamationmark" : "fork.knife")
                            .font(.system(size: 56))
                            .foregroundStyle(.white.opacity(0.45))
                        if imageFetchFailed {
                            Text("Image unavailable")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }

                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.4),
                        .init(color: .black.opacity(0.4), location: 1)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: max(320, 320 + minY))
            }
        }
        .frame(height: 320)
        .coordinateSpace(name: "scroll")
    }

    // MARK: - Body card

    private var bodyCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Source + title
            VStack(alignment: .leading, spacing: 8) {
                SourceBadge(type: recipe.sourceType, label: recipe.sourceLabel)
                Text(recipe.title)
                    .font(.system(size: 28, weight: .bold))
                    .tracking(-0.4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Metadata row
            metadataRow
                .padding(.horizontal, 16)
                .padding(.top, 18)

            // Segmented tabs
            Picker("", selection: $currentTab) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    Text(LocalizedStringKey(tab.rawValue)).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 20)

            // Tab content
            Group {
                switch currentTab {
                case .ingredients: ingredientsTab
                case .steps:       stepsTab
                case .notes:       notesTab
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            // Actions
            actionsSection
                .padding(.horizontal, 16)
                .padding(.top, 24)

            // Local copy note
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "archivebox")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .padding(.top, 1)
                Text("This recipe is saved locally. You keep it even if the original link disappears.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(Color.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 60)
        }
        .background(Color(.systemGroupedBackground))
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24))
        .offset(y: -24)
    }

    // MARK: - Metadata row

    private var metadataRow: some View {
        HStack {
            metaItem(icon: "clock", label: "Time", value: "\(recipe.timeMin) min")
            Divider().frame(height: 32)
            metaItem(icon: "flame", label: "Difficulty", value: recipe.localizedDifficulty)
            Divider().frame(height: 32)
            // Servings stepper
            VStack(spacing: 4) {
                Text("Servings")
                    .font(.system(size: 11))
                    .tracking(0.3)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Button {
                        servings = max(1, servings - 1)
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(theme.accent)
                            .frame(width: 26, height: 26)
                            .background(Color(.tertiarySystemFill), in: Circle())
                    }
                    Text("\(servings)")
                        .font(.system(size: 16, weight: .semibold))
                        .monospacedDigit()
                    Button {
                        servings += 1
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(theme.accent)
                            .frame(width: 26, height: 26)
                            .background(Color(.tertiarySystemFill), in: Circle())
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private func metaItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .tracking(0.3)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .tracking(-0.2)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Ingredients tab

    private var ingredientsTab: some View {
        let all = recipe.ingredients
        let threshold = 8
        let visible = showAllIngredients ? all : Array(all.prefix(threshold))

        return VStack(spacing: 0) {
            if ratio != 1 {
                Text(servings == 1
                    ? "Quantities adjusted for \(servings) serving"
                    : "Quantities adjusted for \(servings) servings")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(theme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(theme.accent.opacity(0.08))
            }
            ForEach(Array(visible.enumerated()), id: \.offset) { index, ing in
                ingredientRow(ing: ing, index: index)
            }
            if all.count > threshold {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showAllIngredients.toggle() }
                } label: {
                    Text(showAllIngredients
                         ? "Show fewer"
                         : "Show all \(all.count) ingredients")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color(.secondarySystemGroupedBackground))
                        .overlay(alignment: .top) { Divider().padding(.leading, 14) }
                }
                .buttonStyle(.plain)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func ingredientRow(ing: Ingredient, index: Int) -> some View {
        Button {
            if checkedIngredients.contains(index) {
                checkedIngredients.remove(index)
            } else {
                checkedIngredients.insert(index)
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .strokeBorder(
                            checkedIngredients.contains(index) ? theme.accent : Color.secondary.opacity(0.4),
                            lineWidth: 1.5
                        )
                        .frame(width: 22, height: 22)
                    if checkedIngredients.contains(index) {
                        Circle()
                            .fill(theme.accent)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                Text(ing.displayLine(ratio: ratio))
                    .font(.system(size: 15))
                    .tracking(-0.2)
                    .foregroundStyle(checkedIngredients.contains(index) ? .secondary : .primary)
                    .strikethrough(checkedIngredients.contains(index), color: .secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .overlay(alignment: .top) {
                if index > 0 { Divider().padding(.leading, 48) }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Steps tab

    private var stepsTab: some View {
        VStack(spacing: 0) {
            Button {
                showCookMode = true
            } label: {
                Label("Start cook mode", systemImage: "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.accent, in: RoundedRectangle(cornerRadius: 14))
                    .shadow(color: theme.accent.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 14)

            VStack(spacing: 0) {
                ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 14) {
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(theme.accent)
                            .frame(width: 26, height: 26)
                            .background(theme.accent.opacity(0.12), in: Circle())

                        Text(step)
                            .font(.system(size: 15))
                            .tracking(-0.2)
                            .lineSpacing(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .overlay(alignment: .top) {
                        if index > 0 { Divider().padding(.leading, 54) }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Notes tab

    private var notesTab: some View {
        VStack(alignment: .leading) {
            if recipe.notes.isEmpty {
                Text("No notes yet. Tap to add.")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                Text(recipe.notes)
                    .font(.system(size: 15))
                    .tracking(-0.2)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 0) {
            if let urlString = recipe.sourceURL, let url = URL(string: urlString) {
                Link(destination: url) {
                    actionRow(icon: "link", title: "Original source", detail: recipe.sourceLabel, isLast: false)
                }
            }
            Button {} label: {
                actionRow(icon: "pencil", title: "Edit recipe", isLast: false)
            }
            Button { showAddToList = true } label: {
                actionRow(icon: "rectangle.stack.badge.plus", title: "Add to list", isLast: false)
            }
            Button { showArchiveConfirm = true } label: {
                actionRow(
                    icon: recipe.isArchived ? "arrow.uturn.up" : "archivebox",
                    title: recipe.isArchived ? "Unarchive" : "Archive",
                    isLast: true
                )
            }
        }
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        .buttonStyle(.plain)
    }

    private func actionRow(icon: String, title: String, detail: String? = nil, isLast: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(theme.accent)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 15))
                .tracking(-0.2)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .overlay(alignment: .top) {
            if !isLast { Divider().padding(.leading, 50) }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                isFavorite.toggle()
                recipe.isFavorite = isFavorite
                try? context.save()
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? theme.accent : .primary)
            }

            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
            }
        }
    }
}
