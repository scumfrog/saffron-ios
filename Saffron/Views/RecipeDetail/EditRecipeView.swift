import SwiftUI
import PhotosUI

struct EditRecipeView: View {
    let recipe: Recipe

    @Environment(\.dismiss) private var dismiss
    @Environment(AppTheme.self) private var theme

    @State private var title: String
    @State private var coverData: Data?
    @State private var timeMin: Int
    @State private var servings: Int
    @State private var difficulty: String
    @State private var tags: [String]
    @State private var ingredients: [Ingredient]
    @State private var steps: [String]
    @State private var notes: String
    @State private var newTag = ""
    @State private var selectedPhotoItem: PhotosPickerItem?

    init(recipe: Recipe) {
        self.recipe = recipe
        _title       = State(initialValue: recipe.title)
        _coverData   = State(initialValue: recipe.coverData)
        _timeMin     = State(initialValue: recipe.timeMin)
        _servings    = State(initialValue: recipe.servings)
        _difficulty  = State(initialValue: recipe.difficulty)
        _tags        = State(initialValue: recipe.tags)
        _ingredients = State(initialValue: recipe.ingredients)
        _steps       = State(initialValue: recipe.steps)
        _notes       = State(initialValue: recipe.notes)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    coverSection
                    titleSection
                    detailsSection
                    tagsSection
                    ingredientsSection
                    stepsSection
                    notesSection
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(String(localized: "Edit recipe"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) { save() }
                        .fontWeight(.semibold)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: selectedPhotoItem) { loadPhoto() }
        }
    }

    // MARK: - Cover

    private var coverSection: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let data = coverData, let ui = UIImage(data: data) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(theme.accent.opacity(0.18))
                        Image(systemName: "fork.knife")
                            .font(.system(size: 40))
                            .foregroundStyle(theme.accent.opacity(0.5))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)

                Label(String(localized: "Change photo"), systemImage: "camera.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.45), in: Capsule())
                    .padding(12)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Title

    private var titleSection: some View {
        sectionCard(label: String(localized: "Title")) {
            TextField(String(localized: "Recipe title"), text: $title)
                .font(.system(size: 17, weight: .semibold))
                .padding(14)
        }
    }

    // MARK: - Details

    private var detailsSection: some View {
        sectionCard(label: String(localized: "Details")) {
            VStack(spacing: 0) {
                // Time
                HStack {
                    Label(String(localized: "Time"), systemImage: "clock")
                        .font(.system(size: 15))
                    Spacer()
                    counterControl(
                        value: $timeMin,
                        min: 0, step: 5,
                        label: timeMin > 0 ? "\(timeMin) min" : "—"
                    )
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)

                Divider().padding(.leading, 14)

                // Servings
                HStack {
                    Label(String(localized: "Servings"), systemImage: "person.2")
                        .font(.system(size: 15))
                    Spacer()
                    counterControl(
                        value: $servings,
                        min: 1, step: 1,
                        label: "\(servings)"
                    )
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)

                Divider().padding(.leading, 14)

                // Difficulty
                HStack {
                    Label(String(localized: "Difficulty"), systemImage: "flame")
                        .font(.system(size: 15))
                    Spacer()
                    Picker("", selection: $difficulty) {
                        Text(String(localized: "difficulty.easy")).tag("easy")
                        Text(String(localized: "difficulty.medium")).tag("medium")
                        Text(String(localized: "difficulty.hard")).tag("hard")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 190)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Tags

    private var tagsSection: some View {
        sectionCard(label: String(localized: "Tags")) {
            VStack(alignment: .leading, spacing: 0) {
                if !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                HStack(spacing: 4) {
                                    Text("#\(tag)")
                                        .font(.system(size: 13, weight: .medium))
                                    Button { tags.removeAll { $0 == tag } } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                    }
                                }
                                .foregroundStyle(theme.accent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(theme.accent.opacity(0.1), in: Capsule())
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                    }
                    Divider().padding(.leading, 14)
                }

                HStack {
                    TextField(String(localized: "Add tag"), text: $newTag)
                        .font(.system(size: 15))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onSubmit { addTag() }
                    if !newTag.isEmpty {
                        Button(String(localized: "Add")) { addTag() }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(theme.accent)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Ingredients

    private var ingredientsSection: some View {
        sectionCard(label: String(localized: "Ingredients")) {
            VStack(spacing: 0) {
                ForEach(ingredients.indices, id: \.self) { i in
                    HStack(spacing: 8) {
                        Text("\(i + 1)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 18)
                        TextField(
                            String(localized: "Ingredient"),
                            text: Binding(
                                get: { ingredients[i].displayLine() },
                                set: { ingredients[i].name = $0; ingredients[i].quantity = 0; ingredients[i].unit = "" }
                            )
                        )
                        .font(.system(size: 15))
                        Button { ingredients.remove(at: i) } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .overlay(alignment: .top) {
                        if i > 0 { Divider().padding(.leading, 40) }
                    }
                }

                Button {
                    ingredients.append(Ingredient(quantity: 0, unit: "", name: ""))
                } label: {
                    Label(String(localized: "Add ingredient"), systemImage: "plus.circle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(theme.accent)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .top) {
                    if !ingredients.isEmpty { Divider().padding(.leading, 14) }
                }
            }
        }
    }

    // MARK: - Steps

    private var stepsSection: some View {
        sectionCard(label: String(localized: "Steps")) {
            VStack(spacing: 0) {
                ForEach(steps.indices, id: \.self) { i in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(i + 1)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(theme.accent)
                            .frame(width: 22, height: 22)
                            .background(theme.accent.opacity(0.12), in: Circle())
                            .padding(.top, 8)
                        TextField(
                            String(format: String(localized: "Step %lld"), i + 1),
                            text: Binding(
                                get: { steps[i] },
                                set: { steps[i] = $0 }
                            ),
                            axis: .vertical
                        )
                        .font(.system(size: 15))
                        .lineLimit(2...)
                        .padding(.vertical, 10)
                        Button { steps.remove(at: i) } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                                .padding(.top, 10)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    .overlay(alignment: .top) {
                        if i > 0 { Divider().padding(.leading, 46) }
                    }
                }

                Button {
                    steps.append("")
                } label: {
                    Label(String(localized: "Add step"), systemImage: "plus.circle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(theme.accent)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .top) {
                    if !steps.isEmpty { Divider().padding(.leading, 14) }
                }
            }
        }
    }

    // MARK: - Notes

    private var notesSection: some View {
        sectionCard(label: String(localized: "Notes")) {
            TextField(String(localized: "No notes yet. Tap to add."), text: $notes, axis: .vertical)
                .font(.system(size: 15))
                .lineSpacing(3)
                .lineLimit(3...)
                .padding(14)
        }
    }

    // MARK: - Reusable counter control

    private func counterControl(value: Binding<Int>, min: Int, step: Int, label: String) -> some View {
        HStack(spacing: 10) {
            Button { value.wrappedValue = Swift.max(min, value.wrappedValue - step) } label: {
                Image(systemName: "minus")
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 28, height: 28)
                    .background(Color(.tertiarySystemFill), in: Circle())
            }
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .monospacedDigit()
                .frame(minWidth: 54, alignment: .center)
            Button { value.wrappedValue += step } label: {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 28, height: 28)
                    .background(Color(.tertiarySystemFill), in: Circle())
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(theme.accent)
    }

    // MARK: - Section card

    @ViewBuilder
    private func sectionCard<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .tracking(0.4)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            content()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Actions

    private func addTag() {
        let tag = newTag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !tag.isEmpty, !tags.contains(tag) else { newTag = ""; return }
        tags.append(tag)
        newTag = ""
    }

    private func loadPhoto() {
        Task {
            guard let item = selectedPhotoItem,
                  let data = try? await item.loadTransferable(type: Data.self) else { return }
            await MainActor.run { coverData = data }
        }
    }

    private func save() {
        recipe.title       = title.trimmingCharacters(in: .whitespacesAndNewlines)
        recipe.coverData   = coverData
        recipe.timeMin     = timeMin
        recipe.servings    = servings
        recipe.difficulty  = difficulty
        recipe.tags        = tags
        recipe.notes       = notes
        recipe.ingredients = ingredients.filter {
            !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        recipe.steps = steps.filter {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        dismiss()
    }
}
