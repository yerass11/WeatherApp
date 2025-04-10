import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            WeatherView()
            .navigationTitle("Погода")
        }
    }
}

#Preview {
    ContentView()
}
