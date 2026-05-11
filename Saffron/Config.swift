import Foundation

enum Config {
    /// Cloudflare Worker URL for recipe extraction (uses Cloudflare Workers AI, no external key).
    /// Override via scheme environment variable EXTRACTION_API_URL for local dev.
    static let extractionAPIURL: URL = {
        let raw = ProcessInfo.processInfo.environment["EXTRACTION_API_URL"]
            ?? "https://saffron-extractor.genlog.workers.dev/extract"
        guard let url = URL(string: raw) else {
            fatalError("Invalid EXTRACTION_API_URL: \(raw)")
        }
        return url
    }()
}

enum AppGroup {
    static let identifier = "group.com.saffron.app"
    static let pendingURLKey = "pendingRecipeURL"
}
