import Foundation
import UIKit

actor ImageCacheService {
    static let shared = ImageCacheService()
    private let session = URLSession.shared

    /// Downloads an image from `urlString`, compresses to JPEG, and returns the Data.
    /// Returns nil if the URL is invalid or the download fails.
    func fetchImageData(from urlString: String?) async -> Data? {
        guard let urlString, !urlString.isEmpty, let url = URL(string: urlString) else {
            return nil
        }
        guard let (data, _) = try? await session.data(from: url),
              let image = UIImage(data: data) else {
            return nil
        }
        return image.jpegData(compressionQuality: 0.8)
    }
}
