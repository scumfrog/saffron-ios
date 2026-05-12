import SwiftUI
import SwiftData

@main
struct SaffronApp: App {
    let container: ModelContainer
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "onboardingDone")
    @State private var theme = AppTheme()

    init() {
        let config = ModelConfiguration(cloudKitDatabase: .automatic)
        do {
            container = try ModelContainer(for: Recipe.self, RecipeList.self,
                                           configurations: config)
        } catch {
            // Store may be corrupted (e.g. from a failed CloudKit migration).
            // Delete it and start fresh.
            let url = config.url
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: url.deletingPathExtension().appendingPathExtension("store-shm"))
            try? FileManager.default.removeItem(at: url.deletingPathExtension().appendingPathExtension("store-wal"))
            do {
                container = try ModelContainer(for: Recipe.self, RecipeList.self,
                                               configurations: config)
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .environment(theme)
                .tint(theme.accent)
                .preferredColorScheme(theme.preferredColorScheme)
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView {
                        UserDefaults.standard.set(true, forKey: "onboardingDone")
                        showOnboarding = false
                    }
                    .environment(theme)
                }
                .onOpenURL { url in
                    // saffron://add?url=... — triggered by Share Extension
                    guard url.scheme == "saffron", url.host == "add",
                          let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                          let rawURL = components.queryItems?.first(where: { $0.name == "url" })?.value,
                          let recipeURL = URL(string: rawURL) else { return }
                    NotificationCenter.default.post(name: .pendingRecipeURL, object: recipeURL)
                }
        }
    }
}

extension Notification.Name {
    static let pendingRecipeURL = Notification.Name("pendingRecipeURL")
}
