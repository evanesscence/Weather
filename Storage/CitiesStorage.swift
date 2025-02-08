import Foundation

struct CitiesStorage {
    static func loadCities() -> [String] {
        guard let url = Bundle.main.url(forResource: "cities", withExtension: "json") else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([String].self, from: data)
        } catch {
            print("Error loading cities: \(error)")
            return []
        }
    }
}
