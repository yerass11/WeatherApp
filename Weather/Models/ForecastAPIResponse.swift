import Foundation

struct ForecastAPIResponse: Codable {
    let forecast: ForecastData
}

struct ForecastData: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    let date: String
    let day: ForecastDayData
}

struct ForecastDayData: Codable {
    let avgtemp_c: Double
    let condition: WeatherCondition // используем ту же структуру, что и для текущей погоды
}
