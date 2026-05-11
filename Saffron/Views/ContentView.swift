import SwiftUI

struct ContentView: View {
    @Environment(AppTheme.self) private var theme
    @State private var selectedTab: Tab = .home
    // Explicit tag binding ensures Home is selected on first launch
    private let initialTab: Tab = .home
    @State private var showAddRecipe = false

    enum Tab: String, CaseIterable {
        case home, lists, search, settings

        var label: LocalizedStringKey {
            switch self {
            case .home:     "Home"
            case .lists:    "Lists"
            case .search:   "Search"
            case .settings: "Settings"
            }
        }

        var icon: String {
            switch self {
            case .home:     "house"
            case .lists:    "square.grid.2x2"
            case .search:   "magnifyingglass"
            case .settings: "gearshape"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label(Tab.home.label,     systemImage: Tab.home.icon) }
                .tag(Tab.home)

            ListsView()
                .tabItem { Label(Tab.lists.label,    systemImage: Tab.lists.icon) }
                .tag(Tab.lists)

            SearchView()
                .tabItem { Label(Tab.search.label,   systemImage: Tab.search.icon) }
                .tag(Tab.search)

            SettingsView()
                .tabItem { Label(Tab.settings.label, systemImage: Tab.settings.icon) }
                .tag(Tab.settings)
        }
        .tint(theme.accent)
        // FAB overlaid on top — only on Home tab, above the tab bar
        .overlay(alignment: .bottomTrailing) {
            if selectedTab == .home {
                Button { showAddRecipe = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(theme.accent)
                        .clipShape(Circle())
                        .shadow(color: theme.accent.opacity(0.4), radius: 10, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 90)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(duration: 0.2), value: selectedTab)
            }
        }
        .sheet(isPresented: $showAddRecipe) {
            AddRecipeView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .pendingRecipeURL)) { _ in
            selectedTab = .home
            showAddRecipe = true
        }
    }
}
