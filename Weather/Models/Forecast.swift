import Foundation

struct Forecast: Codable, Identifiable {
    var id = UUID()
    let summary: String
}
