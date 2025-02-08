import Foundation
import CoreData

final class DefaultDataManager {
    weak var delegate: MyCitiesPresenterProtocol?
    
    private let coreDataManager = CoreDataManager.shared
    private let network = Network.shared
    private let defaultCities = ["Москва"]
    
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
                delegate?.updateCitiesInTableView()
                print("def")
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
                    let cityEntity = CityEntity(context: coreDataManager.context)
                    cityEntity.id = UUID()
                    cityEntity.name = city
                    cityEntity.condition = weather.current.condition.text
                    cityEntity.feelsLike = String(weather.current.feelslikeC)
                    cityEntity.temperature = String(weather.current.tempC)
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
}
