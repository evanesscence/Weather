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

