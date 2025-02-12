import Foundation

final class WeatherPresenter: WeatherPresenterProtocol {
    weak var cityAddingDelegate: CityAddingProtocol?
    private weak var view: WeatherViewProtocol?
    private var weatherModel: WeatherModel?
    var isNewCity: Bool?
    var isAddingCityFlow: Bool = false
    var selectedCity: String? {
        didSet {
            guard let selectedCity else { return }
            fetchWeather(for: selectedCity)
        }
    }
    
    func configure(view: WeatherViewProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        if selectedCity == nil {
            fetchWeather(for: "Москва")
        }
        
        if let isNewCity {
            view?.showAddButton(if: isNewCity)
        }
        
        view?.hideCitiesListButton(if: isAddingCityFlow)
    }
    
    func addCityToMyCities() {
        guard let weatherModel else { return }
        cityAddingDelegate?.didAddCity(weatherModel)
    }
    
    
    func setPresenter(for view: MyCitiesTableViewController) {
//        let myCitiesPresenter = MyCitiesPresenter(view: view)
//        view.presenter = myCitiesPresenter
    }
    
    func setDelegate(for presenter: MyCitiesPresenterProtocol) {
        presenter.delegate = self
    }
    
    private func fetchWeather(for city: String) {
        Network.shared.fetchWeather(city: city) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let weatherNetworkModel):
                DispatchQueue.main.async {
                    let weatherModel = self.convertToWeatherModel(for: weatherNetworkModel)
                    self.weatherModel = weatherModel
                    self.view?.displayWeather(with: weatherModel)
                }
            case .failure(let error):
                print(error.errorDescription)
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
    
        print(model.location.localtime)
        return weather
    }
    
    private func createWeatherTempText(for temp: Double) -> String {
        let roundTemp = Int(temp)
        return "\(roundTemp)"
    }
}

extension WeatherPresenter: CitySelectionProtocol {
    func didSelectCity(_ city: String) {
        selectedCity = city
    }
}
