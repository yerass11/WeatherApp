import SwiftUI

struct WeatherView: View {
    @StateObject var viewModel = WeatherViewModel()
    @StateObject var locationManager = LocationManager()
    @State private var city: String = "Moscow"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let error = locationManager.locationError {
                        Text("Ошибка определения местоположения: \(error.localizedDescription)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    if !locationManager.cityName.isEmpty {
                        Text("Определено местоположение: \(locationManager.cityName)")
                            .foregroundColor(.blue)
                    }
                    
                    TextField("Введите город", text: $city)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button("Использовать моё местоположение") {
                        if !locationManager.cityName.isEmpty {
                            city = locationManager.cityName
                        }
                    }
                    .padding()
                    
                    Button("Обновить погоду") {
                        viewModel.fetchAllWeatherData(for: city)
                    }
                    .padding()
                    
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
                    
                    weatherSection(title: "Прогноз", state: viewModel.forecastState) {
                        if let forecast = viewModel.forecast {
                            NavigationLink(destination: ForecastDetailView(forecast: forecast)) {
                                Text(forecast.summary)
                                    .font(.body)
                            }
                        }
                    }
                    
                    
                    weatherSection(title: "Качество воздуха", state: viewModel.airQualityState) {
                        if let a = viewModel.airQuality {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("EPA-index: \(a.epaIndex)")
                                Text("PM2.5: \(String(format: "%.1f", a.pm25)) µg/m³")
                                Text("PM10: \(String(format: "%.1f", a.pm10)) µg/m³")
                            }
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
