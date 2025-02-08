protocol WeatherPresenterProtocol: AnyObject {
    var cityAddingDelegate: CityAddingProtocol? { get set }
    var selectedCity: String? { get set }
    var isNewCity: Bool? { get set }
    var isAddingCityFlow: Bool { get set }
    func configure(view: WeatherViewProtocol)
    func viewDidLoad()
    func addCityToMyCities()
    func setPresenter(for view: MyCitiesTableViewController)
    func setDelegate(for presenter: MyCitiesPresenterProtocol)
}
