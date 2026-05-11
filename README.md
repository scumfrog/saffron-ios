# Saffron

A SwiftUI iOS app for saving recipes from any source as permanent local copies. Recipes survive broken or deleted links. iCloud syncs them across devices. No login, no account.

## Features

- **Save from anywhere** — paste a URL (blog, Instagram, TikTok) and let AI extract title, ingredients, and steps
- **Local-first** — recipes are stored as SwiftData models with cover images saved as binary data; they never depend on a live URL
- **iCloud sync** — automatic CloudKit sync across all your devices, no account required
- **Cook mode** — fullscreen step-by-step view with screen-on lock
- **Lists** — organize recipes into custom collections
- **Archive** — hide recipes without deleting them
- **Export** — share all recipes as a JSON backup
- **EN / ES** — full English and Spanish localization

## Tech stack

| Layer | Technology |
|---|---|
| Language | Swift 6 |
| UI | SwiftUI (iOS 17+) |
| Data | SwiftData + CloudKit |
| AI extraction | Cloudflare Worker + Workers AI (llama-3.1-8b) |
| Share capture | Share Extension |
| Localization | `Localizable.xcstrings` (EN + ES) |
| Project gen | XcodeGen (`project.yml`) |

No third-party Swift packages.

## Project structure

```
Saffron/
├── Models/              # SwiftData @Model classes
├── ViewModels/          # @Observable classes
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
│   ├── ExtractionService.swift
│   ├── ExportService.swift
│   └── ImageCacheService.swift
├── Extensions/
└── Resources/           # Assets.xcassets, Localizable.xcstrings
SaffronShareExtension/   # Share Extension target
worker/                  # Cloudflare Worker (Node-style JS)
design/                  # React JSX design prototypes
```

## Getting started

### Prerequisites

- Xcode 15.4+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- Apple Developer account (required for CloudKit + App Groups)
- Cloudflare account (for the worker)

### Build

```bash
# 1. Generate the Xcode project
xcodegen

# 2. Open in Xcode
open Saffron.xcodeproj
```

### Worker

```bash
cd worker
npx wrangler deploy
```

Set the worker URL in `Saffron/Services/Config.swift`:

```swift
static let extractionAPIURL = "https://your-worker.workers.dev/extract"
```

## Architecture

MVVM with `@Observable` (iOS 17 macro, not `ObservableObject`).

- `@Query` for SwiftData fetches directly in views
- `AppTheme` `@Observable` class manages accent color + color scheme, injected app-wide via `.environment(theme)`
- Difficulty stored as `"easy"` / `"medium"` / `"hard"` (English), displayed via `recipe.localizedDifficulty`
- Cover images always persisted as `Data` — never store only a remote URL at rest

## License

MIT
