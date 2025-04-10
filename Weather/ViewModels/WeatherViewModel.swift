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
    // Данные погоды
    @Published var currentWeather: CurrentWeather?
    @Published var forecast: Forecast?
    @Published var radarData: RadarData?
    @Published var airQuality: AirQuality?
    @Published var alerts: WeatherAlerts?
    
    // Состояния загрузки
    @Published var currentWeatherState: LoadingState = .idle
    @Published var forecastState: LoadingState = .idle
    @Published var radarState: LoadingState = .idle
    @Published var airQualityState: LoadingState = .idle
    @Published var alertsState: LoadingState = .idle
    
    private let weatherService = WeatherService()
    
    /// Параллельная загрузка всех компонентов погоды для указанного города
    func fetchAllWeatherData(for city: String) {
        // Устанавливаем все состояния в "loading"
        currentWeatherState = .loading
        forecastState = .loading
        radarState = .loading
        airQualityState = .loading
        alertsState = .loading
        
        Task {
            await withTaskGroup(of: (String, Result<Any, Error>).self) { group in
                let endpoints = ["currentWeather", "forecast", "radar", "airQuality", "alerts"]
                
                // Добавляем задачи для каждого эндпоинта
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
                            case "radar":
                                let data = try await weatherService.fetchRadar(for: city)
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
                
                // Обрабатываем результаты по мере их завершения
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
                    case "radar":
                        switch result {
                        case .success(let data as RadarData):
                            self.radarData = data
                            self.radarState = .loaded
                        case .failure(let error):
                            self.radarState = .failed(error)
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
