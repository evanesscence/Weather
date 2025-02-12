protocol MyCityCellProtocol: AnyObject {
    func configure(with model: WeatherModel)
    func updateTime()
    func setImageWithTransition(with imageName: String)
    func createSnowflake()
    func createRain()
}
