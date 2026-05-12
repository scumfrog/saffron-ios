import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppTheme.self) private var theme
    @AppStorage("iCloudEnabled") private var iCloudEnabled = true
    @AppStorage("preferredUnits") private var preferredUnits = "metric"
    @Environment(\.modelContext) private var context
    @Query private var allRecipes: [Recipe]
    @State private var showExportSheet = false
    @State private var exportError: String?

    var body: some View {
        @Bindable var theme = theme
        NavigationStack {
            Form {
                // Appearance
                Section("Appearance") {
                    Picker(selection: $theme.colorSchemePreference) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    } label: {
                        Label("Color scheme", systemImage: "circle.lefthalf.filled")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Accent color")
                            .font(.subheadline)
                        HStack(spacing: 14) {
                            ForEach(AppTheme.accentOptions, id: \.hex) { option in
                                Button {
                                    theme.accentHex = option.hex
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: option.hex) ?? .gray)
                                            .frame(width: 34, height: 34)
                                        if theme.accentHex == option.hex {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Sync
                Section("Sync") {
                    Toggle(isOn: $iCloudEnabled) {
                        Label("Sync with iCloud", systemImage: "icloud")
                    }
                    .tint(theme.accent)
                    if iCloudEnabled {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundStyle(.green)
                            Text("Synced across all your devices")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Data
                Section("Data") {
                    Button {
                        exportRecipes()
                    } label: {
                        Label("Export all recipes", systemImage: "square.and.arrow.down")
                    }
                    if let error = exportError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    NavigationLink {
                        ArchivedRecipesView()
                            .environment(theme)
                    } label: {
                        Label("Archived recipes", systemImage: "archivebox")
                    }
                }

                // Preferences
                Section("Preferences") {
                    Picker(selection: $preferredUnits) {
                        Text("Metric").tag("metric")
                        Text("Imperial").tag("imperial")
                    } label: {
                        Label("Units", systemImage: "ruler")
                    }

                    NavigationLink {
                        LanguageSettingsView()
                    } label: {
                        Label("Language", systemImage: "globe")
                            .badge(currentLanguageBadge)
                    }
                }

                // About
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Image("SaffronIcon")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                            VStack(spacing: 2) {
                                Text("Saffron")
                                    .font(.system(size: 17, weight: .semibold))
                                Text("Version \(appVersion)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 12)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)

                    NavigationLink("Licenses") { Text("Licenses") }
                    NavigationLink("Privacy policy") { Text("Privacy Policy") }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .tint(theme.accent)
            .sheet(isPresented: $showExportSheet) {
                if let data = try? ExportService.exportJSON(recipes: allRecipes),
                   let url = writeExportFile(data: data) {
                    ShareSheet(items: [url])
                        .presentationDetents([.medium, .large])
                }
            }
        }
    }

    private func exportRecipes() {
        exportError = nil
        do {
            let data = try ExportService.exportJSON(recipes: allRecipes)
            if writeExportFile(data: data) != nil {
                showExportSheet = true
            }
        } catch {
            exportError = error.localizedDescription
        }
    }

    private func writeExportFile(data: Data) -> URL? {
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let url = docs.appendingPathComponent("saffron-recipes.json")
        do {
            // .completeFileProtection = NSFileProtectionComplete: file is
            // inaccessible while the device is locked.
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            return url
        } catch {
            exportError = error.localizedDescription
            return nil
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var currentLanguageBadge: String {
        let code = (UserDefaults.standard.array(forKey: "AppleLanguages") as? [String])?.first
            ?? Locale.current.language.languageCode?.identifier
            ?? "en"
        return code == "es" ? "Español" : "English"
    }
}
