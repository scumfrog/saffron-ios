import Foundation
import UIKit
import OSLog

actor ImageCacheService {
    static let shared = ImageCacheService()
    private let session = URLSession.shared
    private let logger = Logger(subsystem: "app.saffron.ios", category: "ImageCache")

    /// Downloads an image from `urlString`, compresses to JPEG, and returns the Data.
    /// Returns nil if the URL is invalid or the download fails.
    func fetchImageData(from urlString: String?) async -> Data? {
        guard let urlString, !urlString.isEmpty, let url = URL(string: urlString) else {
            return nil
        }
        do {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else {
                logger.warning("Downloaded data is not a valid image: \(url.absoluteString)")
                return nil
            }
            return image.jpegData(compressionQuality: 0.8)
        } catch {
            logger.error("Image download failed [\(url.absoluteString)]: \(error)")
            return nil
        }
    }
}
