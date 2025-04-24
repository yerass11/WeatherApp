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
    @Published var currentWeather: CurrentWeather?
    @Published var forecast: Forecast?
    @Published var airQuality: AirQuality?
    @Published var alerts: WeatherAlerts?
    
    @Published var currentWeatherState: LoadingState = .idle
    @Published var forecastState: LoadingState = .idle
    @Published var airQualityState: LoadingState = .idle
    @Published var alertsState: LoadingState = .idle
    
    var fetchTask: Task<Void, Never>? = nil
    
    private let weatherService = WeatherService()
    
    func fetchAllWeatherData(for city: String) {
        fetchTask?.cancel()
        
        currentWeatherState = .loading
        forecastState = .loading
        airQualityState = .loading
        alertsState = .loading
        
        fetchTask = Task {
            await withTaskGroup(of: (String, Result<Any, Error>).self) { group in
                let endpoints = ["currentWeather", "forecast", "airQuality", "alerts"]
                
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
                            print(data)
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
