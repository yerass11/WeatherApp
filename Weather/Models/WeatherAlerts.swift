import Foundation

struct WeatherAlerts: Codable, Identifiable {
    var id = UUID()
    let message: String
}
