import SwiftGifOrigin
import UIKit

final class MyCityTableViewCell: UITableViewCell, MyCityCellProtocol {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    let gradientLayer = CAGradientLayer()
    private let presenter: MyCityPresenterProtocol = MyCityPresenter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .wGray
        
        presenter.setViewForPresenter(view: self)
        setupGradientLayer()
        setupAnimatedImage()
        
        layer.cornerRadius = 20
        layer.masksToBounds = true
    }
    
    func configure(with model: WeatherModel) {
        presenter.configure(with: model)
        self.condition.text = model.condition
        self.cityName.text = model.cityName
        self.tempLabel.text = model.temperature + "°"
        self.timeLabel.text = DateHelper.getTimeWithOffset(localTime: model.localTime)
    }
    
    func updateTime() {
        guard let time = timeLabel.text else { return }
        self.timeLabel.text = DateHelper.getTimeWithOffset(localTime: time)
    }

    func setImageWithTransition(with imageName: String) {
        UIView.transition(with: weatherImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.weatherImageView.image = UIImage(named: imageName)
        }, completion: nil)
    }
    
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
    
    func createSnowflake() {
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
    
    func createRain() {
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
    
    override func prepareForReuse() {
        presenter.stopTimer()
    }
}
