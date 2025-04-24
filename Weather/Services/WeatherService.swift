import Foundation

class WeatherService {
    private let apiKey = "78307457a0aa4288998153721251004"
    private let cacheTTL: TimeInterval = 300

    private func cacheKey(for endpoint: String, city: String) -> String {
        return "\(endpoint)_\(city.lowercased())"
    }

    func fetchCurrentWeather(for city: String) async throws -> CurrentWeather {
        let key = cacheKey(for: "currentWeather", city: city)
        if let cached: CurrentWeather = WeatherCache.shared.getCachedData(for: key, expiration: cacheTTL) {
            return cached
        }

        guard let q = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(q)&aqi=yes")
        else { throw URLError(.badURL) }

        let (data, resp) = try await URLSession.shared.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let api = try JSONDecoder().decode(WeatherAPIResponse.self, from: data)
        let cw = CurrentWeather(
            temperature: api.current.temp_c,
            condition: api.current.condition.text,
            cityName: api.location.name
        )

        WeatherCache.shared.setCachedData(data: cw, for: key)
        return cw
    }

    func fetchForecast(for city: String) async throws -> Forecast {
        let key = cacheKey(for: "forecast", city: city)
        if let cached: Forecast = WeatherCache.shared.getCachedData(for: key, expiration: cacheTTL) {
            return cached
        }

        guard let q = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(q)&days=3&aqi=no&alerts=no")
        else { throw URLError(.badURL) }

        let (data, resp) = try await URLSession.shared.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let api = try JSONDecoder().decode(ForecastAPIResponse.self, from: data)
        guard let d = api.forecast.forecastday.first else {
            throw URLError(.cannotParseResponse)
        }
        let summary = "Date: \(d.date), Avg Temp: \(d.day.avgtemp_c)°C, \(d.day.condition.text)"
        let f = Forecast(summary: summary)

        WeatherCache.shared.setCachedData(data: f, for: key)
        return f
    }

    func fetchAirQuality(for city: String) async throws -> AirQuality {
        let key = cacheKey(for: "airQuality", city: city)
        if let cached: AirQuality = WeatherCache.shared.getCachedData(for: key, expiration: cacheTTL) {
            return cached
        }

        let raw = try await fetchCurrentWeatherRaw(for: city)
        let apiAQ = raw.current.air_quality
        let aq = AirQuality(pm25: apiAQ.pm2_5, pm10: apiAQ.pm10, epaIndex: apiAQ.us_epa_index)

        WeatherCache.shared.setCachedData(data: aq, for: key)
        return aq
    }

    func fetchAlerts(for city: String) async throws -> WeatherAlerts {
        let key = cacheKey(for: "alerts", city: city)
        if let cached: WeatherAlerts = WeatherCache.shared.getCachedData(for: key, expiration: cacheTTL) {
            return cached
        }

        let al = WeatherAlerts(message: "No alerts")

        WeatherCache.shared.setCachedData(data: al, for: key)
        return al
    }

    private func fetchCurrentWeatherRaw(for city: String) async throws -> WeatherAPIResponse {
        guard let q = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(q)&aqi=yes")
        else { throw URLError(.badURL) }

        let (data, resp) = try await URLSession.shared.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(WeatherAPIResponse.self, from: data)
    }
}
