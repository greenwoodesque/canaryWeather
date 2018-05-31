//
//  Location.swift
//  canaryForecast
//
//  Created by David Greenwood on 5/28/18.
//  Copyright © 2018 David Greenwood. All rights reserved.
//

import Foundation
import CoreData

final class Location: NSManagedObject, Managed {
    @NSManaged var locality: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var forecasts: Set<Forecast>?
}

extension Location {
    static func findOrCreate(in managedObjectContext: NSManagedObjectContext, latitude: Double, longitude: Double, locality: String) -> Location {
        let predicate = NSPredicate(format: "%K BEGINSWITH %@", #keyPath(Location.locality), locality)
        let location = Location.findOrCreate(in: managedObjectContext, matching: predicate) { location in
            location.latitude = latitude
            location.longitude = longitude
            location.locality = locality
        }
        managedObjectContext.saveOrRollback()
        return location
    }
}
