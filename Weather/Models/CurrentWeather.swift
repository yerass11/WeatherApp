import Foundation

struct CurrentWeather: Codable, Identifiable {
    let id = UUID()
    let temperature: Double
    let condition: String
    let cityName: String
}
