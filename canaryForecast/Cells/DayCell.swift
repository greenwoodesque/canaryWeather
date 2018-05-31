//
//  DayCell.swift
//  canaryForecast
//
//  Created by David Greenwood on 5/28/18.
//  Copyright © 2018 David Greenwood. All rights reserved.
//

import UIKit

class DayCell: UITableViewCell {

    @IBOutlet var firstLabel: UILabel!
    @IBOutlet var secondLabel: UILabel!
    @IBOutlet var firstValue: UILabel!
    @IBOutlet var secondValue: UILabel!

    func configure(firstLabel: String, secondLabel: String, firstValue: String, secondValue: String) {
        self.firstLabel.text = firstLabel
        self.secondLabel.text = secondLabel
        self.firstValue.text = firstValue 
        self.secondValue.text = secondValue
    }
}
