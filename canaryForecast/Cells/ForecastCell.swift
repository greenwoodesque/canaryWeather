//
//  ForecastCell.swift
//  canaryForecast
//
//  Created by David Greenwood on 5/27/18.
//  Copyright © 2018 David Greenwood. All rights reserved.
//

import UIKit

class ForecastCell: UICollectionViewCell {
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var weatherImage: UIImageView!
    
    func configure(withItem item: Forecast) {
        
        if let icon = item.icon {
            weatherImage.image = UIImage(named: icon)
        }
        
        dayLabel.text = DateHelper.shared.formattedDate(item.time)

        let tempHigh = item.temperatureHigh > -1000 ? item.temperatureHigh.roundedToString() : "NA"
        let tempLow = item.temperatureLow > -1000 ? item.temperatureLow.roundedToString() : "NA"
        
        tempLabel.text = "Temp \(tempHigh)/\(tempLow)"
    }
}
