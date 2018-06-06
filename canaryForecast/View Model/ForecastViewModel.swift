//
//  ForecastViewModel.swift
//  canaryForecast
//
//  Created by David Greenwood on 5/31/18.
//  Copyright © 2018 David Greenwood. All rights reserved.
//

import UIKit
import CoreData

class ForecastViewModel {
    
    var location: Location?
    var locations = [Location]() //Used only to keep strong references, never accessed directly
    var locationController: GeoLocationController!
    var collectionViewSource: CollectionViewSource!
    var managedObjectContext: NSManagedObjectContext
    var onLocationChange: (Location) -> ()
    weak var collectionView: UICollectionView?
    weak var daySelectionDelegate: DaySelectionDelegate?
    
    init(context: NSManagedObjectContext, collectionView: UICollectionView, location: Location?, historyView: Bool, daySelectionDelegate: DaySelectionDelegate, onLocationChange: @escaping (Location) -> ()) {
        self.managedObjectContext = context
        self.collectionView = collectionView
        self.location = location
        self.onLocationChange = onLocationChange
        self.daySelectionDelegate = daySelectionDelegate
        locationController = GeoLocationController(delegate: self)

        if historyView {
            showPastForecasts()
        }
        else if locationController.isAuthorized {
            //Fetch all locations on initial load
            locations = Location.fetch(in: managedObjectContext)
            retrieveLocation()
            if let location = location {
                onLocationChange(location)
            }
        }
    }
    
    func loadForecastFromAPI(resource: Resource<[ForecastUnmanaged]>, success: @escaping ([ForecastUnmanaged])->(), failure: @escaping ()->()) {
        Webservice().load(resource: resource) { result in
            guard let result = result else {
                DispatchQueue.main.async {
                    failure()
                }
                return
            }
            DispatchQueue.main.async {
                success(result)
            }
        }
    }
    
    func retrieveLocation() {
        locationController.retrieveCurrentLocation { [weak self] retrievedLocation, placemark in
            guard let s = self, let locality = placemark?.locality,
                let latitude = retrievedLocation?.coordinate.latitude,
                let longitude = retrievedLocation?.coordinate.longitude else {
                    print("Location incomplete.")
                    return
            }
            let location = Location.findOrCreate(in: s.managedObjectContext, latitude: latitude, longitude: longitude, locality: locality)
            s.location = location
            s.showForecasts()
            s.onLocationChange(location)
        }
    }
    
    func switchLocationTo(newLocation: Location) {
        if newLocation != location {
            location = newLocation
            showForecasts()
            onLocationChange(newLocation)
        }
    }
    
    func showForecasts() {
        if let storedForecasts = getStoredCurrentForecasts() {
            collectionViewSource = CollectionViewSource(collectionView: collectionView!, items: storedForecasts, delegate: daySelectionDelegate!)
        }
        else {
            getForecast()
        }
    }
    
    @objc func getForecast() {
        guard let location = location else {
            print("Trying to get forecast without location.")
            return
        }
        let forecastURL = URL(string: "\(forecastEndpointBase)\(location.latitude),\(location.longitude)?\(forecastEndpointExclusions)")
        
        let forecastResource = Resource<[ForecastUnmanaged]>(url: forecastURL!, parse: ForecastUnmanaged.parse)
        
        loadForecastFromAPI(resource: forecastResource,
                            success: { [weak self] items in
                                guard let s = self else {return}
                                var forecasts = [Forecast]()
                                for item in items {
                                    let predicate = NSPredicate(format: "%K == %@ && %K BEGINSWITH %@", #keyPath(Forecast.time), item.time as NSDate, #keyPath(Forecast.location.locality), location.locality)
                                    let retrievedForecast = Forecast.resetOrCreate(in: s.managedObjectContext, matching: predicate) { forecast in
                                        forecast.set(with: item, for: location)
                                    }
                                    forecasts.append(retrievedForecast)
                                }
                                if !s.managedObjectContext.saveOrRollback() {
                                    print("Failed to save context.")
                                }
                                s.collectionViewSource = CollectionViewSource(collectionView: s.collectionView!, items: forecasts, delegate: s.daySelectionDelegate!)
            }, failure: {
                print("Failed to download forecast.")
        }
        )
    }
    
    func getStoredCurrentForecasts() -> [Forecast]? {
        guard let location = location, let forecasts = location.forecasts, forecasts.count > 7 else { return nil }
        let startOfToday = Date().startOfDay
        let filtered = forecasts.filter {
            $0.time >= startOfToday
        }
        return filtered.sorted { $1.time > $0.time }
    }
    
    func showPastForecasts() {
        guard let location = location, let forecasts = location.forecasts else { return }
        let startOfToday = Date().startOfDay
        let filtered = forecasts.filter {
            $0.time < startOfToday
        }
        let items = filtered.sorted { $1.time > $0.time }
        collectionViewSource = CollectionViewSource(collectionView: collectionView!, items: items, delegate: daySelectionDelegate!)
    }
}

extension ForecastViewModel: LocationSearcchDelegate {
    func switchLocationTo(latitude: Double, longitude: Double, locality: String) {
        let newLocation = Location.findOrCreate(in: managedObjectContext, latitude: latitude, longitude: longitude, locality: locality)
        locations.append(newLocation)
        switchLocationTo(newLocation: newLocation)
    }
}

extension ForecastViewModel: GeoLocationControllerDelegate {
    func geoLocationDidChangeAuthorizationStatus(authorized: Bool) {
        if authorized && location == nil {
            retrieveLocation()
        }
    }
}
