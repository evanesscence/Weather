import Foundation
import CoreData

final class DefaultDataManager {
    weak var delegate: MyCitiesPresenterProtocol?
    
    private let coreDataManager = CoreDataManager.shared
    private let cityEntityService = CityEntityService.shared
    private let network = Network.shared
    private var defaultCities = ["Москва"]
    
    func getDefaultCities() -> [String] {
        defaultCities
    }
    
    func loadDefaultCitiesIfNeeded() {
        let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        
        do {
            let count = try coreDataManager.context.count(for: request)
            if count == 0 {
                loadDefaultCities()
            } else {
                defaultCities = cityEntityService.getCitiesNames()
                delegate?.updateCitiesInTableView()
            }
        } catch {
            print("Failed to check city count: \(error)")
        }
    }
    
    private func loadDefaultCities() {
        let dispatchGroup = DispatchGroup()
        for city in defaultCities {
            dispatchGroup.enter()
            Network.shared.fetchWeather(city: city) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let weather):
                    let weatherModel = convertToWeatherModel(for: weather)
                    cityEntityService.addCity(weatherModel)
                case .failure(let error):
                    print(error.errorDescription)
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.coreDataManager.saveContext()
        
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                delegate?.updateCitiesInTableView()
            }
        }
    }
    
    private func convertToWeatherModel(for model: WeatherNetworkModel) -> WeatherModel {
        let weather = WeatherModel(
            cityName: model.location.name,
            temperature: createWeatherTempText(for: model.current.tempC),
            feelsLike: "Ощущается как " + createWeatherTempText(for: model.current.feelslikeC) + "°",
            condition: model.current.condition.text,
            order: 0,
            localTime: DateHelper.extractTime(from: model.location.localtime)
        )
        
        return weather
    }
    
    private func createWeatherTempText(for temp: Double) -> String {
        let roundTemp = Int(temp)
        return "\(roundTemp)"
    }
}
