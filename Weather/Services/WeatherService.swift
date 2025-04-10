import Foundation

class WeatherService {
    // Ваш API-ключ от WeatherAPI.com
    private let apiKey = "78307457a0aa4288998153721251004"
    
    /// Получение текущей погоды с WeatherAPI.com
    func fetchCurrentWeather(for city: String) async throws -> CurrentWeather {
        guard let urlEncodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(urlEncodedCity)&aqi=yes")
        else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        // Проверяем, что сервер вернул статус 200
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(WeatherAPIResponse.self, from: data)
        // Преобразуем полученные данные в модель нашего приложения
        let currentWeather = CurrentWeather(
            temperature: apiResponse.current.temp_c,
            condition: apiResponse.current.condition.text,
            cityName: apiResponse.location.name
        )
        return currentWeather
    }
    
    /// Получение прогноза (на 3 дня) с WeatherAPI.com
    func fetchForecast(for city: String) async throws -> Forecast {
        guard let urlEncodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(urlEncodedCity)&days=3&aqi=no&alerts=no")
        else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(ForecastAPIResponse.self, from: data)
        if let firstDay = apiResponse.forecast.forecastday.first {
            let summary = "Date: \(firstDay.date), Avg Temp: \(firstDay.day.avgtemp_c)°C, \(firstDay.day.condition.text)"
            return Forecast(summary: summary)
        } else {
            throw URLError(.cannotParseResponse)
        }
    }
    
    func fetchAirQuality(for city: String) async throws -> AirQuality {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        return AirQuality(index: 42)
    }
    
    func fetchAlerts(for city: String) async throws -> WeatherAlerts {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return WeatherAlerts(message: "No alerts")
    }
}
