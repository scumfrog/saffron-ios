import Foundation

// MARK: - Response types

struct ExtractedRecipe: Decodable {
    var title: String
    var coverURL: String?
    var sourceLabel: String
    var timeMin: Int?
    var servings: Int?
    var difficulty: String?
    var tags: [String]
    var ingredients: [ExtractedIngredient]
    var steps: [String]
}

struct ExtractedIngredient: Decodable {
    var quantity: Double
    var unit: String
    var name: String

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        unit = try c.decode(String.self, forKey: .unit)
        name = try c.decode(String.self, forKey: .name)
        // AI sometimes returns "al gusto", "½", etc. instead of a number
        if let n = try? c.decode(Double.self, forKey: .quantity) {
            quantity = n
        } else {
            quantity = 0
        }
    }

    private enum CodingKeys: String, CodingKey { case quantity, unit, name }
}

// MARK: - Service

actor ExtractionService {
    static let shared = ExtractionService()
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        return URLSession(configuration: config)
    }()

    func extract(url: URL) async throws -> ExtractedRecipe {
        var request = URLRequest(url: Config.extractionAPIURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["url": url.absoluteString])

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw ExtractionError.badResponse
        }

        guard http.statusCode == 200 else {
            let message = (try? JSONDecoder().decode(ErrorBody.self, from: data))?.message
                ?? "Server error \(http.statusCode)"
            throw ExtractionError.serverError(message)
        }

        return try JSONDecoder().decode(ExtractedRecipe.self, from: data)
    }

    private struct ErrorBody: Decodable { let message: String }
}

enum ExtractionError: LocalizedError {
    case badResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .badResponse:         return String(localized: "Invalid server response.")
        case .serverError(let m):  return m
        }
    }
}
