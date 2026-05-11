import Foundation

enum SourceType: String, Codable, CaseIterable {
    case instagram
    case blog
    case manual
    case photo

    var displayName: String {
        switch self {
        case .instagram: return "Instagram"
        case .blog:      return String(localized: "Blog")
        case .manual:    return String(localized: "Manual")
        case .photo:     return String(localized: "Photo")
        }
    }

    var systemImage: String {
        switch self {
        case .instagram: return "camera.circle"
        case .blog:      return "globe"
        case .manual:    return "pencil"
        case .photo:     return "camera"
        }
    }
}
