import SwiftUI
import SwiftData

@main
struct SaffronApp: App {
    let container: ModelContainer
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "onboardingDone")
    @State private var theme = AppTheme()

    init() {
        let schema = Schema([Recipe.self, RecipeList.self])
        if let ckContainer = try? ModelContainer(
            for: schema,
            configurations: ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        ) {
            container = ckContainer
        } else if let localContainer = try? ModelContainer(
            for: schema,
            configurations: ModelConfiguration(schema: schema)
        ) {
            container = localContainer
        } else {
            fatalError("Failed to create ModelContainer")
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
