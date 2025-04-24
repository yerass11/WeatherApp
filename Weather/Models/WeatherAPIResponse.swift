import Foundation

struct WeatherAPIResponse: Codable {
    let location: WeatherLocation
    let current: WeatherCurrent
}

struct WeatherLocation: Codable {
    let name: String
}

struct WeatherCurrent: Codable {
    let temp_c: Double
    let condition: WeatherCondition
    let humidity: Int
    let air_quality: AirQualityAPI
}

struct WeatherCondition: Codable {
    let text: String
    let icon: String
}
