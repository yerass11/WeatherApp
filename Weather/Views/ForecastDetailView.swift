import SwiftUI

struct ForecastDetailView: View {
    let forecast: Forecast
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Детальный прогноз")
                .font(.largeTitle)
            Text(forecast.summary)
                .font(.body)
        }
        .padding()
        .navigationTitle("Прогноз")
    }
}

struct ForecastDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastDetailView(forecast: Forecast(summary: "Пример детального прогноза"))
    }
}
