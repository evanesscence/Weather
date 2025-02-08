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
    
//    init(view: MyCitiesViewProtocol) {
//        self.view = view
//        self.defaultDataManager = DefaultDataManager.shared
//        self.cityEntityService = CityEntityService.shared
//        self.cities = CitiesStorage.loadCities()
//        updateCitiesInTableView()
//    }
    
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
    
    func getCityName(at indexPath: IndexPath) -> String? {
        guard let cityName = fetchedResultController.object(at: indexPath).name else { return nil }
        return cityName
    }
    
    func getCondition(at indexPath: IndexPath) -> String? {
        guard let condition = fetchedResultController.object(at: indexPath).condition else { return nil }
        return condition
    }
    
    func getTemperature(at indexPath: IndexPath) -> String? {
        guard let temperature = fetchedResultController.object(at: indexPath).temperature else { return nil }
        return temperature
    }
    
    func getOrder(at indexPath: IndexPath) -> Int16 {
        let order = fetchedResultController.object(at: indexPath).order
        return order
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
        print("reload")
        do {
            try fetchedResultController.performFetch()
            view?.reloadData()
        } catch {
            print(error)
        }
    }
    
    func moveCity(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        cityEntityService.changeOrder(from: sourceIndex, to: destinationIndex)
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


