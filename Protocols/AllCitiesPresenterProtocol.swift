import Foundation
protocol AllCitiesPresenterProtocol: AnyObject {
    var delegate: CitySelectionProtocol? { get set }
    init(view: AllCitiesViewProtocol)
    func getAllCities() -> [String]
    func didSelectCity(at indexPath: IndexPath)
    func updateAllCities(with data: [String])
}
