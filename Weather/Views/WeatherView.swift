import SwiftUI

struct WeatherView: View {
    @StateObject var viewModel = WeatherViewModel()
    @StateObject var locationManager = LocationManager()
    @State private var city: String = "Moscow"  // Значение по умолчанию
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Если произошла ошибка определения местоположения, выводим сообщение
                    if let error = locationManager.locationError {
                        Text("Ошибка определения местоположения: \(error.localizedDescription)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Если удалось определить город, выводим его
                    if !locationManager.cityName.isEmpty {
                        Text("Определено местоположение: \(locationManager.cityName)")
                            .foregroundColor(.blue)
                    }
                    
                    // Поле для ввода города
                    TextField("Введите город", text: $city)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Кнопка для использования определённого местоположения
                    Button("Использовать моё местоположение") {
                        if !locationManager.cityName.isEmpty {
                            city = locationManager.cityName
                        }
                    }
                    .padding()
                    
                    // Кнопка для запроса погоды
                    Button("Обновить погоду") {
                        viewModel.fetchAllWeatherData(for: city)
                    }
                    .padding()
                    
                    // Пример секции для текущей погоды
                    weatherSection(title: "Текущая погода", state: viewModel.currentWeatherState) {
                        if let weather = viewModel.currentWeather {
                            VStack {
                                Text(weather.cityName)
                                    .font(.largeTitle)
                                Text("\(weather.temperature, specifier: "%.1f")°C")
                                    .font(.title)
                                Text(weather.condition)
                                    .font(.headline)
                            }
                        }
                    }
                    
                    // Прогноз с навигацией на подробное представление
                    weatherSection(title: "Прогноз", state: viewModel.forecastState) {
                        if let forecast = viewModel.forecast {
                            NavigationLink(destination: ForecastDetailView(forecast: forecast)) {
                                Text(forecast.summary)
                                    .font(.body)
                            }
                        }
                    }
                    
                    
                    weatherSection(title: "Качество воздуха", state: viewModel.airQualityState) {
                        if let airQuality = viewModel.airQuality {
                            Text("Индекс качества: \(airQuality.index)")
                                .font(.body)
                        }
                    }
                    
                    weatherSection(title: "Предупреждения", state: viewModel.alertsState) {
                        if let alerts = viewModel.alerts {
                            Text(alerts.message)
                                .font(.body)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Погода")
        }
    }
    
    @ViewBuilder
    private func weatherSection<Content: View>(title: String, state: LoadingState, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            switch state {
            case .idle:
                Text("Введите город и нажмите кнопку")
                    .foregroundColor(.gray)
            case .loading:
                ProgressView("Загрузка \(title.lowercased())...")
            case .loaded:
                content()
            case .failed(let error):
                Text("Ошибка: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}
