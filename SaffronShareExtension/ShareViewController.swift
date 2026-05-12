import UIKit
import UniformTypeIdentifiers

/// Share Extension entry point.
/// Reads the shared URL, saves it to the App Group container,
/// then deep-links back to the main app via the saffron:// URL scheme.
final class ShareViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        extractURL()
    }

    // MARK: - URL extraction

    private func extractURL() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            finish()
            return
        }

        for item in items {
            guard let attachments = item.attachments else { continue }
            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] object, _ in
                        if let url = object as? URL {
                            self?.handle(url: url)
                        } else {
                            self?.finish()
                        }
                    }
                    return
                }
            }
        }
        finish()
    }

    private func handle(url: URL) {
        // 1. Persist to App Group so the main app picks it up on next foreground
        let defaults = UserDefaults(suiteName: AppGroup.identifier)
        defaults?.set(url.absoluteString, forKey: AppGroup.pendingURLKey)
        defaults?.synchronize()

        // 2. Deep-link to open the main app directly
        let encoded = url.absoluteString
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let appURL = URL(string: "saffron://add?url=\(encoded)") {
            openMainApp(with: appURL)
        }

        finish()
    }

    private func openMainApp(with url: URL) {
        var responder: UIResponder? = self
        while let r = responder {
            if let app = r as? UIApplication {
                app.open(url, options: [:], completionHandler: nil)
                return
            }
            responder = r.next
        }
    }

    private func finish() {
        DispatchQueue.main.async {
            self.extensionContext?.completeRequest(returningItems: nil)
        }
    }
}

// MARK: - AppGroup constants (mirrored from main target)

private enum AppGroup {
    static let identifier = "group.app.saffron.ios"
    static let pendingURLKey = "pendingRecipeURL"
}
