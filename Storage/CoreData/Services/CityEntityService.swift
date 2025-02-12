import CoreData

final class CityEntityService {
    static let shared = CityEntityService()
    private init() {}
    private let coreDataManager = CoreDataManager.shared
    
    lazy var fetchedResultController: NSFetchedResultsController<CityEntity> = {
        let fetchRequest = CityEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        let fetchedResultController: NSFetchedResultsController<CityEntity> = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataManager.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return fetchedResultController
    }()

    func addCity(_ model:  WeatherModel) {
        let newCity = CityEntity(context: coreDataManager.context)
        newCity.id = UUID()
        newCity.name = model.cityName
        newCity.condition = model.condition
        newCity.feelsLike = model.feelsLike
        newCity.temperature = model.temperature
        newCity.order = getNextOrderIndex()
        newCity.localTime = model.localTime
        
        coreDataManager.saveContext()
    }
    
    private func getNextOrderIndex() -> Int16 {
        let fetchRequest: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        fetchRequest.fetchLimit = 1
        
        do {
            if let lastCity = try coreDataManager.context.fetch(fetchRequest).first {
                return lastCity.order + 1
            }
        } catch {
            print("Ошибка при получении order: \(error)")
        }
        return 0 // Если нет городов, начинаем с 0
    }
    
    func changeOrder(from sourceIndex: Int, to destinationIndex: Int) {
        guard let firstItemId = fetchedResultController.object(
            at: IndexPath(
                row: sourceIndex,
                section: 0
            )
        ).id,
              let secondItemId = fetchedResultController.object(
                at: IndexPath(
                    row: destinationIndex,
                    section: 0
                )
              ).id 
        else {
            return
        }
        
        if let firstCity = getCity(with: firstItemId),
           let secondCity = getCity(with: secondItemId) {
            let firstCityOrder = firstCity.order
            firstCity.order += 1
            secondCity.order = firstCityOrder
            coreDataManager.saveContext()
        }
    }
    
    private func getCity(with id: UUID) -> CityEntity? {
        let fetchRequest = CityEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let cities = try coreDataManager.context.fetch(fetchRequest)
            return cities.first // Возвращаем первый найденный город
        } catch {
            print("Ошибка при получении города: \(error)")
            return nil
        }
    }
    
    func updateCity(named cityName: String, with model: WeatherModel) {
        do {
            if let city = getCity(by: cityName) {
                city.localTime = model.localTime
                city.condition = model.condition
                city.feelsLike = model.feelsLike
                city.temperature = model.temperature
                
                try coreDataManager.context.save()
            } else {
                print("⚠️ Город \(cityName) не найден")
            }
        }
        catch {
            print("❌ Ошибка при обновлении города: \(error)")
        }
    }
        
    private func getCity(by name: String) -> CityEntity? {
        let request = CityEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let cities = try coreDataManager.context.fetch(request)
            return cities.first
        } catch {
            print("❌ Ошибка при получении города: \(error)")
        }
        
        return nil
    }
    
    func getCitiesNames() -> [String] {
        let request = CityEntity.fetchRequest()
        
        do {
            let cities = try coreDataManager.context.fetch(request)
            return cities.compactMap { $0.name }
        } catch {
            print("Ошибка при загрузке городов: \(error)")
            return []
        }
    }
    
    func getWeatherModel(by name: String) -> WeatherModel? {
        guard let cityEntity = getCity(by: name),
              let temperature = cityEntity.temperature,
              let name = cityEntity.name,
              let feelsLike = cityEntity.feelsLike,
              let condition = cityEntity.condition,
              let localTime = cityEntity.localTime
        else { return nil }
        let weatherModel = WeatherModel(
            cityName: name,
            temperature: temperature,
            feelsLike: feelsLike,
            condition: condition,
            order: cityEntity.order,
            localTime: localTime
        )
        return weatherModel
    }
    
    func removeCityFromCoreData(_ cityName: String) {
        let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", cityName)
        
        do {
            let cities = try coreDataManager.context.fetch(request)
            for city in cities {
                coreDataManager.context.delete(city)
            }
            coreDataManager.saveContext()
        } catch {
            print("Failed to delete city: \(error)")
        }
    }
}

