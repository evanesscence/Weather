import Foundation

final class MyCityPresenter: MyCityPresenterProtocol {
    private weak var view: MyCityCellProtocol?
    private var cityName: String?
    private let networkService = Network.shared
    private let cityEntityService = CityEntityService.shared
    private var shortIntervalTimer: Timer?
    private var longIntervalTimer: Timer?
    
    func setViewForPresenter(view: MyCityCellProtocol? = nil) {
        self.view = view
    }
    
    func configure(with model: WeatherModel) {
        var imagesNames = [String]()
        
        if model.condition.lowercased().contains("туман") || model.condition.lowercased().contains("дым") {
            imagesNames = ["DFog-1", "DFog-2", "NCloudy-1"]
        }
        
        else if  model.condition.lowercased().contains("облач") {
            imagesNames = ["DCloudy-1", "NCloudy-1"]
        }
        
        else if model.condition.lowercased().contains("пасмурно") {
            imagesNames = ["DCloudy-1", "NCloudy-1"]
        }
        
        else if model.condition.lowercased().contains("дожд") {
            imagesNames = ["DRain-1", "DRain-2", "NCloudy-1", "NFair-1", "NFair-2"]
            view?.createRain()
        }
        
        else if model.condition.lowercased().contains("ясно") || model.condition.lowercased().contains("солнечно") {
            imagesNames = ["DFair-1", "DFair-2", "DFair-1", "NFair-1", "NFair-2"]
        }
        
        else if model.condition.lowercased().contains("снег") {
            imagesNames = ["DSnow-1", "DSnow-2", "NSnow-1", "NSnow-2"]
            view?.createSnowflake()
        }
        
        self.cityName = model.cityName
        updateImageForTimeOfDay(for: imagesNames)
        startTimer()
    }
    
    private func updateImageForTimeOfDay(for images: [String]) {
        let hour = Calendar.current.component(.hour, from: Date())
        var newImages = [String]()

        switch hour {
        case 6..<18:
            newImages = images.filter { $0.lowercased().hasPrefix("d") }
        default:
            newImages = images.filter { $0.lowercased().hasPrefix("n") }
        }
        
        guard let imageName = newImages.randomElement() else { return }
        view?.setImageWithTransition(with: imageName)
    }
    
    func stopTimer() {
        shortIntervalTimer?.invalidate()
        longIntervalTimer?.invalidate()
    }
    
    private func startTimer() {
        shortIntervalTimer?.invalidate()
        longIntervalTimer?.invalidate()
        
        shortIntervalTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.view?.updateTime()
        }
        
        longIntervalTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
            guard let self = self, let cityName = cityName else { return }
            self.updateCity(for: cityName)
        }
    }
    
    private func updateCity(for city: String) {
        networkService.fetchWeather(city: city) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let weatherNetworkModel):
                DispatchQueue.main.async {
                    let weatherModel = self.convertToWeatherModel(for: weatherNetworkModel)
                    self.cityEntityService.updateCity(named: weatherModel.cityName, with: weatherModel)
                    self.view?.configure(with: weatherModel)
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
        
        return weather
    }
    
    private func createWeatherTempText(for temp: Double) -> String {
        let roundTemp = Int(temp)
        return "\(roundTemp)"
    }
}
