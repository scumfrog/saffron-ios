import SwiftUI

struct LanguageSettingsView: View {
    @Environment(AppTheme.self) private var theme
    @State private var selected: String = currentLanguageCode()
    @State private var showRestartAlert = false

    private let languages: [(code: String, displayName: String)] = [
        ("en", "English"),
        ("es", "Español"),
    ]

    var body: some View {
        Form {
            Section {
                ForEach(languages, id: \.code) { lang in
                    Button {
                        guard lang.code != selected else { return }
                        UserDefaults.standard.set([lang.code], forKey: "AppleLanguages")
                        UserDefaults.standard.synchronize()
                        selected = lang.code
                        showRestartAlert = true
                    } label: {
                        HStack {
                            Text(lang.displayName)
                                .foregroundStyle(.primary)
                            Spacer()
                            if selected == lang.code {
                                Image(systemName: "checkmark")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(theme.accent)
                            }
                        }
                    }
                }
            } footer: {
                Text("language.restart.footer")
            }
        }
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.inline)
        .alert("language.restart.title", isPresented: $showRestartAlert) {
            Button("OK") {}
        } message: {
            Text("language.restart.message")
        }
    }
}

private func currentLanguageCode() -> String {
    (UserDefaults.standard.array(forKey: "AppleLanguages") as? [String])?.first
        ?? Locale.current.language.languageCode?.identifier
        ?? "en"
}
