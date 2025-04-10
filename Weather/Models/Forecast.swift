import Foundation

struct Forecast: Codable, Identifiable {
    let id = UUID()
    let summary: String
}
