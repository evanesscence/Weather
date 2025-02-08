protocol WeatherViewProtocol: AnyObject {
    var presenter: WeatherPresenterProtocol { get }
    func displayWeather(with model: WeatherModel)
    func showAddButton(if isNewCity: Bool)
    func hideCitiesListButton(if isNewFlow: Bool)
}
