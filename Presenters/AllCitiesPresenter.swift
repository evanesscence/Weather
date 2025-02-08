import Foundation

final class AllCitiesPresenter: AllCitiesPresenterProtocol {
    weak var delegate: CitySelectionProtocol?
    private weak var view: AllCitiesViewProtocol?
    private var allCities: [String] = []
    
    init(view: AllCitiesViewProtocol) {
        self.view = view
    }
    
    func getAllCities() -> [String] {
        allCities
    }
    
    func didSelectCity(at indexPath: IndexPath) {
        let selectedCity = allCities[indexPath.row]
        delegate?.didSelectCity(selectedCity)
    }
    
    func updateAllCities(with data: [String]) {
        allCities = data
    }
}
