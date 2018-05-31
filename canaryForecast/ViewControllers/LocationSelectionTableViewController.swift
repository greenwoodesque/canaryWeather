//
//  LocationSelectionTableViewController.swift
//  canaryForecast
//
//  Created by David Greenwood on 5/30/18.
//  Copyright © 2018 David Greenwood. All rights reserved.
//

import UIKit
import CoreData

class LocationSelectionTableViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext!
    var items = [Location]()
    var callback: (Location) -> Void
    
    required init(with context: NSManagedObjectContext, callback: @escaping (Location) -> Void) {
        managedObjectContext = context
        self.callback = callback
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let locations = Location.findAll(in: managedObjectContext) else {
            dismiss(animated: false, completion: nil)
            return
        }
        items = locations
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = items[indexPath.row].locality
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callback(items[indexPath.row])
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
