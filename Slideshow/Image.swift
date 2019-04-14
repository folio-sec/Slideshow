import Foundation

struct Image: Codable {
    let id: String
    let description: String?
    let alt_description: String?
    let urls: [String: URL]
}
