# Saffron — iOS Recipe App

## What this is
Saffron is a SwiftUI iOS app for saving recipes from any source (Instagram, TikTok, blogs, manual entry, photos) as permanent local copies. Recipes survive broken or deleted links. iCloud syncs them across devices. No login, no account.

## Tech stack
| Layer | Technology |
|---|---|
| Language | Swift 6 |
| UI | SwiftUI |
| Min deployment | iOS 17.0 |
| Local data | SwiftData |
| Cloud sync | CloudKit via SwiftData (`cloudKitDatabase: .automatic`) |
| AI extraction | Cloudflare Worker → Claude Haiku |
| Share capture | Share Extension (SaffronShareExtension target) |
| Localization | EN + ES (`Localizable.xcstrings`) |

No third-party dependencies unless strictly necessary. Prefer Apple frameworks.

## Architecture: MVVM + @Observable
Use the iOS 17 `@Observable` macro, **not** `ObservableObject`/`@Published`.

```
Saffron/
├── Models/          # SwiftData @Model classes
├── ViewModels/      # @Observable classes, one per screen or feature
├── Views/
│   ├── Home/
│   ├── Lists/
│   ├── Search/
│   ├── RecipeDetail/
│   ├── CookMode/
│   ├── AddRecipe/
│   ├── Settings/
│   └── Onboarding/
├── Services/
│   ├── ExtractionService.swift   # Cloudflare Worker client
│   └── ImageCacheService.swift   # local image persistence
├── Extensions/      # Swift/SwiftUI extension files
└── Resources/       # Assets.xcassets, Localizable.xcstrings
SaffronShareExtension/           # Share Extension target
```

## Data model

```swift
@Model class Recipe {
    var id: UUID
    var title: String
    var coverData: Data?           // image stored locally, never a remote URL at rest
    var sourceURL: String?
    var sourceLabel: String
    var sourceType: SourceType     // .instagram | .blog | .manual | .photo
    var isFavorite: Bool
    var isArchived: Bool
    var timeMin: Int
    var servings: Int
    var difficulty: String         // stored: "easy" | "medium" | "hard"; display via localizedDifficulty
    var tags: [String]
    var ingredients: [Ingredient]  // Codable struct {qty, unit, name}
    var steps: [String]
    var notes: String
    var addedAt: Date
    var lists: [RecipeList]
}

@Model class RecipeList {
    var id: UUID
    var name: String
    var icon: String               // SF Symbol name (e.g. "fork.knife")
    var colorHex: String
    var recipes: [Recipe]
}
```

## Recipe extraction flow
1. User pastes URL or triggers Share Extension from another app
2. App sends `POST /extract` to Cloudflare Worker with `{ url }`
3. Worker fetches page HTML + calls Cloudflare Workers AI (`@cf/meta/llama-3.1-8b-instruct`) with structured prompt
4. Returns `ExtractedRecipe` JSON: title, ingredients, steps, coverURL, timeMin, servings
5. App downloads cover image → stores as `coverData: Data`
6. User reviews and edits in preview screen before saving

**Worker endpoint**: configured via `EXTRACTION_API_URL` in `Config.swift` (not hardcoded).
**API key**: stored in Cloudflare Worker env vars, never in the app bundle.

## Share Extension
- Target: `SaffronShareExtension`
- Accepts: `public.url`
- Writes URL to App Group shared container (`group.com.saffron.app`)
- Main app reads pending URL on `scenePhase` change to `.active`

## iCloud sync
`ModelConfiguration(cloudKitDatabase: .automatic)` — zero custom sync code.
Requires CloudKit entitlement and iCloud capability in the main target.
Share Extension uses a separate `ModelConfiguration` with the same App Group container but **no** CloudKit (sync only from main app).

## Conventions
- `@Observable` everywhere, no `ObservableObject`
- `@Query` macro in views for SwiftData fetches
- `AppTheme` `@Observable` class manages accent color + color scheme; injected via `.environment(theme)` from `SaffronApp`; use `theme.accent` everywhere instead of `Color("Accent")`
- `String(localized: "key")` for every user-facing string, no raw string literals in views
- SF Symbols for all icons — match the icon names used in `/design/screens.jsx`
- No `print()` in production paths — use `Logger` from `OSLog`
- Images always persisted locally (`coverData`) — never store only a remote URL

## Design reference
All screens are prototyped in `/design/` as React JSX files. Treat them as the source of truth for layout, hierarchy, copy, and interaction patterns. When in doubt, open `design/Cocina.html` in a browser.

Key design tokens:
- Accent palette: Terracotta `#C4623F`, Sage `#6B8E5A`, Tomate `#B8453A`, Lavanda `#8B6FB8`, Eucalyptus `#3F8B7A`
- Background light: `#F2F2F7` | dark: `#000000`
- Card light: `#FFFFFF` | dark: `#1C1C1E`
- Typography: SF Pro (system font), large titles 34pt/700, section headers 22pt/700

## Build requirements
- Xcode 15.4+
- iOS 17.0 SDK
- Apple Developer account (for CloudKit + App Groups entitlements)
- Cloudflare Worker deployed separately (see `/worker/`)
