import Foundation

struct CurrentWeather: Codable, Identifiable {
    var id = UUID()
    let temperature: Double
    let condition: String
    let cityName: String
}
