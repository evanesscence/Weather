import SwiftGifOrigin
import UIKit

final class MyCityTableViewCell: UITableViewCell {
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .wGray
        
        setupGradientLayer()
        setupAnimatedImage()
        
        layer.cornerRadius = 20
        layer.masksToBounds = true
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
        
        self.condition.text = model.condition
        self.cityName.text = model.cityName
        self.tempLabel.text = createWeatherTempText(for: model.temperature)
    }

    private func createWeatherTempText(for temp: String) -> String {
        var tempString = temp
        
        if tempString.removeLast() == "°" {
            return String(tempString) + "°"
        }
        
        tempString = String(Int(Double(temp) ?? 0))
        return tempString + "°"
    }
    
    func updateImageForTimeOfDay(for images: [String]) {
        let hour = Calendar.current.component(.hour, from: Date())
        var newImages = [String]()

        switch hour {
        case 6..<18:
            newImages = images.filter { $0.lowercased().hasPrefix("d") }
        case 18..<6:
            newImages = images.filter { $0.lowercased().hasPrefix("n") }
        default:
            newImages = images
        }
        
        guard let imageName = newImages.randomElement() else { return }
        
        UIView.transition(with: weatherImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.weatherImageView.image = UIImage(named: imageName)
        }, completion: nil)
    }
    
//    private func load(from url: String) {
//        gradientLayer.isHidden = false
//        UIImage.gif(url: url) { image in
//            DispatchQueue.main.async {
//                if let gifImage = image {
////                    UIView.transition(
////                        with: self.animatedImage,
////                        duration: 0.5,
////                        options: .transitionCrossDissolve,
////                        animations: {
//                            self.animatedImage.image = gifImage
////                        },
////                        completion: { _ in
//                            self.gradientLayer.isHidden = true 
////                        }
////                    )
//                } else {
//                    print("Не удалось загрузить GIF")
//                }
//            }
//        }
//    }
    
    private func setupAnimatedImage() {
        weatherImageView.layer.cornerRadius = 16
        weatherImageView.layer.masksToBounds = true
        weatherImageView.layer.addSublayer(gradientLayer)
    }
    
    private func setupGradientLayer() {
        gradientLayer.frame = layer.bounds
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.systemGray6
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
    }
    
    private func createSnowflake() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            let screenWidth = self.contentView.bounds.width
            let snowflakeSize = CGFloat.random(in: 5...8)
            let snowflake = UIView(frame: CGRect(
                x: CGFloat.random(in: 0...screenWidth),
                y: -snowflakeSize,
                width: snowflakeSize,
                height: snowflakeSize
            ))
            
            snowflake.backgroundColor = .white.withAlphaComponent(0.5)
            snowflake.layer.cornerRadius = snowflakeSize / 2
            
            self.contentView.addSubview(snowflake)
      
            let animationDuration = TimeInterval.random(in: 8...10)
            
            UIView.animate(withDuration: animationDuration, animations: {
                snowflake.frame.origin.y = self.contentView.bounds.height - 24 + snowflakeSize
                snowflake.alpha = 0.1
            }, completion: { _ in
                snowflake.removeFromSuperview()
            })
        }
    }
    
    private func createRain() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            guard let self else { return }
            let screenWidth = contentView.bounds.width
            let snowflakeSize = CGFloat.random(in: 5...8)
            let snowflake = UIView(frame: CGRect(
                x: CGFloat.random(in: 0...screenWidth),
                y: -snowflakeSize,
                width: snowflakeSize / 4,
                height: snowflakeSize
            ))
            
            snowflake.backgroundColor = .white.withAlphaComponent(0.5)
            snowflake.layer.cornerRadius = snowflakeSize / 5
            contentView.addSubview(snowflake)
            
            let animationDuration = TimeInterval.random(in: 2...3)
            
            UIView.animate(withDuration: animationDuration, animations: {
                snowflake.frame.origin.y = self.contentView.bounds.height - 24 + snowflakeSize
                snowflake.alpha = 0.1
            }, completion: { _ in
                snowflake.removeFromSuperview()
            })
        }
    }
}
