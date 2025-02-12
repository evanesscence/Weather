import UIKit

final class WeatherViewController: UIViewController, WeatherViewProtocol {
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var citiesListButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addCityButton: UIButton!
    @IBOutlet weak var feelsLike: UILabel!
    @IBOutlet weak var weatherState: UILabel!
    @IBOutlet weak var tempC: UILabel!
    @IBOutlet weak var cityName: UILabel!
    let gradientLayer = CAGradientLayer()
    
    var presenter: WeatherPresenterProtocol = WeatherPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.configure(view: self)
        presenter.viewDidLoad()
        
        setupGradientLayer()
    }
    
    func updateImageForTimeOfDay(for images: [String]) {
        let hour = Calendar.current.component(.hour, from: Date())
        var newImages = [String]()

        switch hour {
        case 6..<18:
            newImages = images.filter { $0.lowercased().hasPrefix("d") }
        case 18..<25:
            newImages = images.filter { $0.lowercased().hasPrefix("n") }
    
        default:
            newImages = images
        }
        
        guard let imageName = newImages.randomElement() else { return }
        
        UIView.transition(with: weatherImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.weatherImageView.image = UIImage(named: imageName)
        }, completion: nil)
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
            createRain()
        }
        
        else if model.condition.lowercased().contains("ясно") || model.condition.lowercased().contains("солнечно") {
            imagesNames = ["DFair-1", "DFair-2", "DFair-1", "NFair-1", "NFair-2"]
              
        }
        
        else if model.condition.lowercased().contains("снег") {
            imagesNames = ["DSnow-1", "DSnow-2", "NSnow-1", "NSnow-2"]
            createSnowflake()
        }
        
        updateImageForTimeOfDay(for: imagesNames)
    }
    
    private func setupGradientLayer() {
        gradientLayer.frame = view.layer.bounds
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.systemGray6
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        weatherImageView.layer.addSublayer(gradientLayer)
    }
    
    @IBAction func showCities(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func addButton(_ sender: Any) {
        presenter.addCityToMyCities()
        dismiss(animated: true)
    }
    
    func displayWeather(with model: WeatherModel) {
        self.cityName.text = model.cityName
        self.tempC.text = model.temperature + "°"
        self.weatherState.text = model.condition
        self.feelsLike.text = model.feelsLike
        
        configure(with: model)
    }
    
    func showAddButton(if isNewCity: Bool) {
        cancelButton.isHidden = false
        addCityButton.isHidden = !isNewCity
    }
    
    func hideCitiesListButton(if isNewFlow: Bool) {
        citiesListButton.isHidden = isNewFlow
    }
    
    private func createSnowflake() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            let screenWidth = self.view.bounds.width
            let snowflakeSize = CGFloat.random(in: 5...8)
            let snowflake = UIView(frame: CGRect(
                x: CGFloat.random(in: 0...screenWidth),
                y: -snowflakeSize,
                width: snowflakeSize,
                height: snowflakeSize
            ))
            
            snowflake.backgroundColor = .white.withAlphaComponent(0.5)
            snowflake.layer.cornerRadius = snowflakeSize / 2
            
            self.view.addSubview(snowflake)
      
            let animationDuration = TimeInterval.random(in: 8...10)
            
            UIView.animate(withDuration: animationDuration, animations: {
                snowflake.frame.origin.y = self.view.bounds.height - 24 + snowflakeSize
                snowflake.alpha = 0.1
            }, completion: { _ in
                snowflake.removeFromSuperview()
            })
        }
    }
    
    private func createRain() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            guard let self else { return }
            let screenWidth = view.bounds.width
            let snowflakeSize = CGFloat.random(in: 5...8)
            let snowflake = UIView(frame: CGRect(
                x: CGFloat.random(in: 0...screenWidth),
                y: -snowflakeSize,
                width: snowflakeSize / 4,
                height: snowflakeSize
            ))
            
            snowflake.backgroundColor = .white.withAlphaComponent(0.5)
            snowflake.layer.cornerRadius = snowflakeSize / 5
            view.addSubview(snowflake)
            
            let animationDuration = TimeInterval.random(in: 2...3)
            
            UIView.animate(withDuration: animationDuration, animations: {
                snowflake.frame.origin.y = self.view.bounds.height - 24 + snowflakeSize
                snowflake.alpha = 0.1
            }, completion: { _ in
                snowflake.removeFromSuperview()
            })
        }
    }
}
