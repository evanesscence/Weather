import Foundation
import CoreData

protocol MyCitiesPresenterProtocol: AnyObject, CitySelectionProtocol {
    var delegate: CitySelectionProtocol? { get set }
    var fetchedResultController: NSFetchedResultsController<CityEntity> { get }
    func didLoad(view: MyCitiesViewProtocol)
    func shouldShowWeatherOfMainCity()
    func getNumberOfRowsInSection(_ section: Int) -> Int
    func getCity(at indexPath: IndexPath) -> WeatherModel?
    func removeCityFromCoreData(_ cityName: String)
    func addCity(_ model: WeatherModel)
    func configure(for view: WeatherViewProtocol)
    func showWeatherViewController()
    func didSelectCity(at indexPath: IndexPath)
    func isDefaultCitiesContainsCity(at indexPath: IndexPath) -> Bool
    func trailingSwipeActionsConfigurationForRowAt(indexPath: IndexPath)
    func updateSearchResults(for presenter: AllCitiesPresenterProtocol, with searchText: String)
    func updateCitiesInTableView()
    func moveCity(from sourceIndex: Int, to destinationIndex: Int)
}
