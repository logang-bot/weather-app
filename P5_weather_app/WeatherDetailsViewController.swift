//
//  WeatherDetailsViewController.swift
//  P5_weather_app
//
//  Created by Alvaro Choque on 22/6/22.
//

import UIKit
import SVProgressHUD

class WeatherDetailsViewController: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryFlagImage: UIImageView!
    
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var tempMinLabel: UILabel!
    @IBOutlet weak var tempMaxLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    var urlSearch: String!
    var index: Int!
    
    var data: WeatherItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Weather Details"
        getData()
    }
    
    func getData() {
        SVProgressHUD.show()
        guard let url = URL(string: urlSearch) else {return}
        NetworkManager.shared.get(WeatherResponse.self, from: url){result in
    
            switch result {
            case .success(let responseData):
                self.data = responseData.list[self.index]
                self.setData()
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in print("OK")}))
                self.present(alert, animated: true, completion: nil)
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func setData() {
        self.mainLabel.text = data?.weather.first?.main
        self.descriptionLabel.text = data?.weather.first?.weatherDescription
        
        
        if let url = URL(string: "https://openweathermap.org/img/wn/\(data?.weather.first?.icon ?? "03n")@2x.png") {
            ImageManager.shared.loadImage(from: url){ result in
                switch result {
                case .success(let image):
                    self.weatherImage.image = image
                case.failure(let error):
                    print(error)
                }
            }
        }
        
        self.nameLabel.text = data?.name
        self.countryLabel.text = data?.sys.country
        
        if let url = URL(string: "https://countryflagsapi.com/png/\(data?.sys.country ?? "")") {
            ImageManager.shared.loadImage(from: url){ result in
                switch result {
                case .success(let image):
                    self.countryFlagImage.image = image
                case.failure(let error):
                    print(error)
                }
            }
        }
        
        if let temp = data?.main.temp,
            let feelsLike = data?.main.feelsLike,
            let min = data?.main.tempMin,
            let max = data?.main.tempMax,
            let pressure = data?.main.pressure,
            let humidity = data?.main.humidity,
            let wind = data?.wind.speed
        {
            self.tempLabel.text = "Temperature: \(String(temp))"
            self.feelsLikeLabel.text = "Feels Like: \(String(feelsLike))"
            self.tempMinLabel.text = "Min: \(String(min))"
            self.tempMaxLabel.text = "Max: \(String(max))"
            self.pressureLabel.text = "Pressure: \(String(pressure))"
            self.humidityLabel.text = "Humidity: \(String(humidity))"
            self.windLabel.text = "Wind Speed: \(String(wind))"
        }
        
        
        
    }
}
