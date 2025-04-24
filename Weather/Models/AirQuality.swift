import Foundation

struct AirQuality: Codable, Identifiable {
    var id = UUID()
    let pm25: Double
    let pm10: Double
    let epaIndex: Int
}

struct AirQualityAPI: Codable {
    let pm2_5: Double
    let pm10: Double
    let us_epa_index: Int
    
    enum CodingKeys: String, CodingKey {
        case pm2_5 = "pm2_5", pm10, us_epa_index = "us-epa-index"
    }
}
