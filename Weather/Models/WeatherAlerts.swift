import Foundation

struct WeatherAlerts: Codable, Identifiable {
    let id = UUID()
    let message: String
}
