import Foundation
import CoreData

final class MyCitiesPresenter: MyCitiesPresenterProtocol {
    var selectedCity: String?
    weak var view: MyCitiesViewProtocol?
    weak var delegate: CitySelectionProtocol?
    
    let fetchedResultController = CityEntityService.shared.fetchedResultController
    private let cityEntityService: CityEntityService = CityEntityService.shared
    private var defaultDataManager: DefaultDataManager = DefaultDataManager()
    
    private var cities: [String] = []
    private var shouldShowMainCityWeather: Bool = false
    
    init() {
        self.defaultDataManager.delegate = self
        defaultDataManager.loadDefaultCitiesIfNeeded()
    }
    
    func didLoad(view: MyCitiesViewProtocol) {
        self.view = view
        self.cities = CitiesStorage.loadCities()
        shouldShowMainCityWeather = true
    }
    
    func shouldShowWeatherOfMainCity() {
        if shouldShowMainCityWeather {
            view?.showWeatherOfMainCity()
            shouldShowMainCityWeather = false
        }
    }
    
    func getNumberOfRowsInSection(_ section: Int) -> Int {
        guard let section = fetchedResultController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func getAllCities() -> [String] {
        cities
    }
    
    func getCity(at indexPath: IndexPath) -> WeatherModel? {
        guard
            let cityName = fetchedResultController.object(at: indexPath).name,
            let city = cityEntityService.getWeatherModel(by: cityName)
        else { return nil }
        return city
    }
    
    func removeCityFromCoreData(_ cityName: String) {
        cityEntityService.removeCityFromCoreData(cityName)
    }
    
    func addCity(_ model: WeatherModel) {
        cityEntityService.addCity(model)
    }
    
    func configure(for view: WeatherViewProtocol) {
        guard let selectedCity,
        let isNewCity = fetchedResultController.fetchedObjects?.contains(where: { $0.name == selectedCity })
        else { return }
        
        view.presenter.isNewCity = !isNewCity
        view.presenter.selectedCity = selectedCity
        view.presenter.isAddingCityFlow = true
        view.presenter.cityAddingDelegate = self
    }
    
    func showWeatherViewController() {
        view?.showWeatherViewController()
    }
    
    func didSelectCity(at indexPath: IndexPath) {
        guard let cityName = fetchedResultController.object(at: indexPath).name else { return }
        delegate?.didSelectCity(cityName)
    }
    
    func isDefaultCitiesContainsCity(at indexPath: IndexPath) -> Bool {
        guard let cityName = fetchedResultController.object(at: indexPath).name else { return false }
        return !defaultDataManager.getDefaultCities().contains(cityName) 
    }
    
    func trailingSwipeActionsConfigurationForRowAt(indexPath: IndexPath) {
        guard let cityToRemove = fetchedResultController.object(at: indexPath).name else { return }
        removeCityFromCoreData(cityToRemove)
    }
    
    func updateSearchResults(for presenter: AllCitiesPresenterProtocol, with searchText: String) {
        let filteredCities = cities.filter { $0.lowercased().hasPrefix(searchText) }
        presenter.delegate = self
        presenter.updateAllCities(with: filteredCities)
    }
    
    func updateCitiesInTableView() {
        do {
            try fetchedResultController.performFetch()
            view?.reloadData()
        } catch {
            print(error)
        }
    }
    
    func moveCity(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
            guard let cities = fetchedResultController.fetchedObjects else { return }
        
            // Изменяем порядок (order) городов
            let movedCity = cities[sourceIndex]
            var updatedCities = cities

            updatedCities.remove(at: sourceIndex)
            updatedCities.insert(movedCity, at: destinationIndex)

            for (index, city) in updatedCities.enumerated() {
                city.order = Int16(index)  // Обновляем поле order
            }

        CoreDataManager.shared.saveContext()
    }
}

extension MyCitiesPresenter: CitySelectionProtocol {
    func didSelectCity(_ city: String) {
        selectedCity = city
        delegate?.didSelectCity(city)
        showWeatherViewController()
    }
}

extension MyCitiesPresenter: CityAddingProtocol {
    func didAddCity(_ model: WeatherModel) {
        addCity(model)
        view?.updateSearchController()
    }
}


