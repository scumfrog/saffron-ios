import Foundation

enum Config {
    /// Cloudflare Worker URL for recipe extraction (uses Cloudflare Workers AI, no external key).
    /// Override via scheme environment variable EXTRACTION_API_URL for local dev.
    static let extractionAPIURL: URL = {
        let raw = ProcessInfo.processInfo.environment["EXTRACTION_API_URL"]
            ?? "https://saffron-extractor.genlog.workers.dev/v1/extract"
        guard let url = URL(string: raw) else {
            fatalError("Invalid EXTRACTION_API_URL: \(raw)")
        }
        return url
    }()
}

enum AppGroup {
    static let identifier = "group.app.saffron.ios"
    static let pendingURLKey = "pendingRecipeURL"
}

enum WorkerAuth {
    /// API key sent as `X-API-Key` on every extraction request.
    /// Production value is injected at build time via Secrets.xcconfig → Info.plist.
    /// Falls back to the `WORKER_API_KEY` scheme env var for local dev / simulator runs.
    /// The Worker validates this against the `WORKER_API_KEY` Cloudflare secret.
    static let apiKey: String = {
        Bundle.main.infoDictionary?["WorkerAPIKey"] as? String
            ?? ProcessInfo.processInfo.environment["WORKER_API_KEY"]
            ?? ""
    }()
}
