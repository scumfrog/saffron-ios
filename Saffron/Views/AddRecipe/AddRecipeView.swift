import SwiftUI
import SwiftData

struct AddRecipeView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var viewModel = AddRecipeViewModel()
    @State private var showManualEntry = false
    @FocusState private var urlFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.stage {
                case .input:      inputView
                case .extracting: extractingView
                case .preview:    previewView
                case .failed(let msg): failedView(message: msg)
                }
            }
            .navigationTitle("New recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                if case .preview = viewModel.stage {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { saveRecipe() }
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .sheet(isPresented: $showManualEntry) {
            ManualRecipeView { dismiss() }
                .environment(theme)
        }
        .onReceive(NotificationCenter.default.publisher(for: .pendingRecipeURL)) { note in
            if let url = note.object as? URL {
                viewModel.urlText = url.absoluteString
                Task { await viewModel.extract() }
            }
        }
    }

    // MARK: - Input stage

    private var inputView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // URL input
                VStack(alignment: .leading, spacing: 6) {
                    Text("Paste a link")
                        .font(.caption)
                        .tracking(0.4)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)

                    HStack(spacing: 10) {
                        Image(systemName: "link")
                            .foregroundStyle(.secondary)
                        TextField("https://...", text: $viewModel.urlText)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($urlFieldFocused)
                            .onSubmit { Task { urlFieldFocused = false; await viewModel.extract() } }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)
                }

                Button {
                    urlFieldFocused = false
                    Task { await viewModel.extract() }
                } label: {
                    Label("Extract recipe", systemImage: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.accent, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                        .shadow(color: theme.accent.opacity(0.35), radius: 8, x: 0, y: 4)
                }
                .disabled(!viewModel.canExtract)
                .opacity(viewModel.canExtract ? 1 : 0.5)
                .padding(.horizontal, 16)

                // Divider
                HStack(spacing: 12) {
                    Rectangle().fill(Color(.separator)).frame(height: 0.5)
                    Text("or")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Rectangle().fill(Color(.separator)).frame(height: 0.5)
                }
                .padding(.horizontal, 16)

                Button {
                    showManualEntry = true
                } label: {
                    Label(String(localized: "Create manually"), systemImage: "pencil")
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 16)

                if let platform = viewModel.unsupportedPlatform {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .padding(.top, 1)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("unsupported.url.title")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text(String(format: String(localized: "unsupported.url.message"), platform))
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                                .lineSpacing(2)
                        }
                    }
                    .padding(14)
                    .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                } else {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "archivebox")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .padding(.top, 1)
                        Text("We save a local copy so you never lose the recipe, even if the link disappears.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .lineSpacing(2)
                    }
                    .padding(14)
                    .background(Color.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - Extracting stage

    private var extractingView: some View {
        VStack(spacing: 24) {
            Spacer()
            ProgressView()
                .scaleEffect(1.4)
                .tint(theme.accent)
            VStack(spacing: 6) {
                Text("Extracting recipe…")
                    .font(.system(size: 19, weight: .semibold))
                    .tracking(-0.4)
                Text("Reading ingredients and steps.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Preview stage

    private var previewView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(.top, 1)
                    Text("Review before saving. Tap any field to edit.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(.label).opacity(0.75))
                }
                .padding(14)
                .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

                // Title
                VStack(alignment: .leading, spacing: 6) {
                    Text("Title")
                        .font(.caption)
                        .tracking(0.4)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                    TextField("Recipe title", text: $viewModel.editedTitle, axis: .vertical)
                        .font(.system(size: 19, weight: .bold))
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                }

                // Ingredients
                VStack(alignment: .leading, spacing: 6) {
                    Text("Ingredients")
                        .font(.caption)
                        .tracking(0.4)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 0) {
                        ForEach(viewModel.editedIngredients.indices, id: \.self) { i in
                            HStack(spacing: 8) {
                                Text("\(i + 1)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 18)
                                TextField("Ingredient", text: Binding(
                                    get: { viewModel.editedIngredients[i].name },
                                    set: { viewModel.editedIngredients[i].name = $0 }
                                ))
                                .font(.system(size: 15))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .overlay(alignment: .top) {
                                if i > 0 { Divider().padding(.leading, 40) }
                            }
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                }

                // Steps
                VStack(alignment: .leading, spacing: 6) {
                    Text("Steps")
                        .font(.caption)
                        .tracking(0.4)
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 0) {
                        ForEach(viewModel.editedSteps.indices, id: \.self) { i in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(i + 1)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(theme.accent)
                                    .frame(width: 22, height: 22)
                                    .background(theme.accent.opacity(0.12), in: Circle())
                                    .padding(.top, 8)
                                TextField("Step \(i + 1)", text: Binding(
                                    get: { viewModel.editedSteps[i] },
                                    set: { viewModel.editedSteps[i] = $0 }
                                ), axis: .vertical)
                                .font(.system(size: 15))
                                .lineLimit(2...)
                                .padding(.vertical, 10)
                            }
                            .padding(.horizontal, 14)
                            .overlay(alignment: .top) {
                                if i > 0 { Divider().padding(.leading, 46) }
                            }
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - Failed stage

    private func failedView(message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            Text("Extraction failed")
                .font(.system(size: 19, weight: .semibold))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Try again") {
                viewModel.stage = .input
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.accent)
            Spacer()
        }
    }

    // MARK: - Save

    private func saveRecipe() {
        Task {
            guard case .preview(let extracted) = viewModel.stage else { return }
            let coverData = await ImageCacheService.shared.fetchImageData(from: extracted.coverURL)
            let recipe = viewModel.buildRecipe(coverData: coverData)
            await MainActor.run {
                context.insert(recipe)
                try? context.save()
                dismiss()
            }
        }
    }
}
