protocol MyCityPresenterProtocol: AnyObject {
    func setViewForPresenter(view: MyCityCellProtocol?)
    func configure(with model: WeatherModel)
    func stopTimer()
}
