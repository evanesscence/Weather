import Foundation

// MARK: - Weather
struct WeatherNetworkModel: Codable {
    let location: Location
    let current: Current
}

// MARK: - Current
struct Current: Codable {
    let tempC, tempF: Double
    let condition: Condition
    let feelslikeC: Double

    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case tempF = "temp_f"
        case condition
        case feelslikeC = "feelslike_c"
    }
}

// MARK: - Condition
struct Condition: Codable {
    let text: String
}

// MARK: - Location
struct Location: Codable {
    let name, region, country: String
}
