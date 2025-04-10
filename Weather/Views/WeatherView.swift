import SwiftUI

struct WeatherView: View {
    @StateObject var viewModel = WeatherViewModel()
    @State private var city: String = "Moscow" // Значение по умолчанию
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Текстовое поле для ввода города
                    TextField("Введите город", text: $city)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Кнопка для запроса всех данных
                    Button("Обновить погоду") {
                        viewModel.fetchAllWeatherData(for: city)
                    }
                    .padding()
                    
                    // Текущая погода
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
                    
                    // Прогноз
                    weatherSection(title: "Прогноз", state: viewModel.forecastState) {
                        if let forecast = viewModel.forecast {
                            Text(forecast.summary)
                                .font(.body)
                        }
                    }
                    
                    // Радар
                    weatherSection(title: "Радар", state: viewModel.radarState) {
                        if let radar = viewModel.radarData {
                            // Здесь можно добавить AsyncImage или другой компонент для загрузки изображения
                            Text("Радар: \(radar.imageURL)")
                                .font(.body)
                        }
                    }
                    
                    // Качество воздуха
                    weatherSection(title: "Качество воздуха", state: viewModel.airQualityState) {
                        if let airQuality = viewModel.airQuality {
                            Text("Индекс качества воздуха: \(airQuality.index)")
                                .font(.body)
                        }
                    }
                    
                    // Предупреждения
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
    
    /// Вспомогательная функция для генерации секций с разными состояниями загрузки
    @ViewBuilder
    func weatherSection<Content: View>(title: String, state: LoadingState, @ViewBuilder content: @escaping () -> Content) -> some View {
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
