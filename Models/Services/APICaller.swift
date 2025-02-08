import Foundation

final class Network {
    static let shared = Network()
    private init() {}
    
    func fetchWeather(city: String, completion: @escaping (Result<WeatherNetworkModel, NetworkError>) -> Void) {
        guard let urlString = makeURL(city: city) else {
            completion(.failure(.badURL))
            return
        }
        var request = URLRequest(url: urlString)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let weather = try JSONDecoder().decode(WeatherNetworkModel.self, from: data)
                completion(.success(weather))
            } catch {
                completion(.failure(.decodingError(error.localizedDescription)))
            }
        }.resume()
    }
    
    private func makeURL(city: String) -> URL? {
        guard var components = URLComponents(string: Constants.baseURL) else { return nil }
        components.queryItems = [
            URLQueryItem(name: "key", value: Constants.APIKey),
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "lang", value: "ru")
        ]
        return components.url
    }
}

extension Network {
    enum NetworkError: Error {
        case badURL
        case noData
        case networkError(String)
        case decodingError(String)
        case unknownError
        
        var errorDescription: String {
            switch self {
            case .badURL:
                return "Некорректный URL."
            case .noData:
                return "Нет данных в ответе сервера."
            case .networkError(let message):
                return "Ошибка декодирования данных: \(message)"
            case .decodingError(let message):
                return "Ошибка сети: \(message)"
            case .unknownError:
                return "Неизвестная ошибка."
            }
        }
    }
}
