//
//  DayDetailViewController.swift
//  canaryForecast
//
//  Created by David Greenwood on 5/27/18.
//  Copyright © 2018 David Greenwood. All rights reserved.
//

import UIKit

class DayDetailViewController: UIViewController, UITableViewDataSource {

    @IBOutlet var summary: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var item: Forecast!
    let cellID = "detailViewCell"
    
    static func createDayDetailViewController(withItem item: Forecast) -> DayDetailViewController? {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "dayDetailViewController") as? DayDetailViewController else {return nil}
        vc.item = item
        return vc
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationItem.title = DateHelper.shared.formattedDate(item.time)
        summary.text = item.summary ?? "No forecast summary available"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "DayCell", bundle: nil), forCellReuseIdentifier: cellID)
        tableView.dataSource = self
        tableView.reloadData()
    }

    
    // MARK: - TableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var firstLabel: String
        var secondLabel: String
        var firstValue = "NA"
        var secondValue = "NA"
        
        switch indexPath.row {
        case 0:
            firstLabel = "Sunrise"
            secondLabel = "Sunset"
            if let time = item.sunriseTime {
                firstValue = DateHelper.shared.formattedTime(time)
            }
            if let time = item.sunsetTime {
                secondValue = DateHelper.shared.formattedTime(time)
            }
        case 1:
            firstLabel = "High Temp"
            secondLabel = "Low Temp"
            if item.temperatureHigh > -1000 {
                firstValue = item.temperatureHigh.roundedToString()
            }
            if item.temperatureLow > -1000 {
                secondValue = item.temperatureLow.roundedToString()
            }
        case 2:
            firstLabel = "Cloud Cover"
            secondLabel = "UV Index"
            if item.cloudCover >= 0 {
                firstValue = (item.cloudCover*100).roundedToString()
            }
            if item.uvIndex >= 0 {
                secondValue = item.uvIndex.roundedToString()
            }
        case 3:
            firstLabel = "Humidity"
            secondLabel = "Visibility"
            if item.humidity >= 0 {
                firstValue = (item.humidity*100).roundedToString()
            }
            if item.visibility >= 0 {
                secondValue = item.visibility.roundedToString()
            }
        default:
            return UITableViewCell()
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? DayCell else { fatalError("Unexpected cell type") }
        cell.configure(firstLabel: firstLabel, secondLabel: secondLabel, firstValue: firstValue, secondValue: secondValue)
        return cell
    }
}
