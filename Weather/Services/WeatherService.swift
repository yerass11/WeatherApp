import Foundation

class WeatherService {
    
    /// Симуляция получения текущей погоды
    func fetchCurrentWeather(for city: String) async throws -> CurrentWeather {
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 секунды
        return CurrentWeather(temperature: 21.5, condition: "Солнечно", cityName: city)
    }
    
    /// Симуляция получения прогноза
    func fetchForecast(for city: String) async throws -> Forecast {
        try await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 секунды
        return Forecast(summary: "Ожидается небольшая облачность с прояснениями")
    }
    
    /// Симуляция получения данных радара
    func fetchRadar(for city: String) async throws -> RadarData {
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 секунды
        return RadarData(imageURL: "https://example.com/radar.png")
    }
    
    /// Симуляция получения данных о качестве воздуха
    func fetchAirQuality(for city: String) async throws -> AirQuality {
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 секунды
        return AirQuality(index: 42)
    }
    
    /// Симуляция получения предупреждений о погоде
    func fetchAlerts(for city: String) async throws -> WeatherAlerts {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда
        return WeatherAlerts(message: "Никаких предупреждений")
    }
}
