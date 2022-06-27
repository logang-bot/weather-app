//
//  WeatherItemTableViewCell.swift
//  P5_weather_app
//
//  Created by Alvaro Choque on 21/6/22.
//

import UIKit

class WeatherItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var temperaturLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
