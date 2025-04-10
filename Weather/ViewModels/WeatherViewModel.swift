import Foundation
import SwiftUI

enum LoadingState {
    case idle
    case loading
    case loaded
    case failed(Error)
}

@MainActor
class WeatherViewModel: ObservableObject {
    // Данные погодных компонентов
    @Published var currentWeather: CurrentWeather?
    @Published var forecast: Forecast?
    @Published var airQuality: AirQuality?
    @Published var alerts: WeatherAlerts?
    
    // Состояния загрузки для каждого компонента
    @Published var currentWeatherState: LoadingState = .idle
    @Published var forecastState: LoadingState = .idle
    @Published var airQualityState: LoadingState = .idle
    @Published var alertsState: LoadingState = .idle
    
    // Ссылка на текущую задачу для отмены
    var fetchTask: Task<Void, Never>? = nil
    
    private let weatherService = WeatherService()
    
    /// Параллельная загрузка всех компонентов для заданного города с поддержкой отмены
    func fetchAllWeatherData(for city: String) {
        // Отменяем предыдущую задачу, если она ещё выполняется
        fetchTask?.cancel()
        
        // Устанавливаем все состояния в "loading"
        currentWeatherState = .loading
        forecastState = .loading
        airQualityState = .loading
        alertsState = .loading
        
        fetchTask = Task {
            await withTaskGroup(of: (String, Result<Any, Error>).self) { group in
                let endpoints = ["currentWeather", "forecast", "airQuality", "alerts"]
                
                // Добавляем задачи в группу
                for endpoint in endpoints {
                    group.addTask { [weatherService] in
                        do {
                            switch endpoint {
                            case "currentWeather":
                                let data = try await weatherService.fetchCurrentWeather(for: city)
                                return (endpoint, .success(data))
                            case "forecast":
                                let data = try await weatherService.fetchForecast(for: city)
                                return (endpoint, .success(data))
                            case "airQuality":
                                let data = try await weatherService.fetchAirQuality(for: city)
                                return (endpoint, .success(data))
                            case "alerts":
                                let data = try await weatherService.fetchAlerts(for: city)
                                return (endpoint, .success(data))
                            default:
                                throw URLError(.badURL)
                            }
                        } catch {
                            return (endpoint, .failure(error))
                        }
                    }
                }
                
                // По мере завершения обрабатываем результаты
                for await (endpoint, result) in group {
                    switch endpoint {
                    case "currentWeather":
                        switch result {
                        case .success(let data as CurrentWeather):
                            self.currentWeather = data
                            self.currentWeatherState = .loaded
                        case .failure(let error):
                            self.currentWeatherState = .failed(error)
                        default: break
                        }
                    case "forecast":
                        switch result {
                        case .success(let data as Forecast):
                            self.forecast = data
                            self.forecastState = .loaded
                        case .failure(let error):
                            self.forecastState = .failed(error)
                        default: break
                        }
                    case "airQuality":
                        switch result {
                        case .success(let data as AirQuality):
                            self.airQuality = data
                            self.airQualityState = .loaded
                        case .failure(let error):
                            self.airQualityState = .failed(error)
                        default: break
                        }
                    case "alerts":
                        switch result {
                        case .success(let data as WeatherAlerts):
                            self.alerts = data
                            self.alertsState = .loaded
                        case .failure(let error):
                            self.alertsState = .failed(error)
                        default: break
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
}
