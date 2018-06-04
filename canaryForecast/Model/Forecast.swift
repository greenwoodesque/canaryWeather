//
//  Forecast.swift
//  canaryForecast
//
//  Created by David Greenwood on 5/26/18.
//  Copyright © 2018 David Greenwood. All rights reserved.
//

import Foundation
import CoreData

typealias JSONDictionary = [String: AnyObject]

//The Dark Sky forecast API only guarantees a time value
//All other fields may be absent in its response

final class Forecast: NSManagedObject {
    @NSManaged var time: Date
    @NSManaged var summary: String?
    @NSManaged var icon: String?
    @NSManaged var sunriseTime: Date?
    @NSManaged var sunsetTime: Date?
    @NSManaged var precipProbability: Float
    @NSManaged var precipType: String?
    @NSManaged var temperatureHigh: Float
    @NSManaged var temperatureLow: Float
    @NSManaged var visibility: Float
    @NSManaged var humidity: Float
    @NSManaged var uvIndex: Float
    @NSManaged var cloudCover: Float
    @NSManaged var location: Location
}

extension Forecast: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(time), ascending: false)]
    }
}

extension Forecast {
    func set(with f: ForecastUnmanaged, for location: Location) {
        self.time = f.time
        self.summary = f.summary
        self.icon = f.icon
        self.sunriseTime = f.sunriseTime
        self.sunsetTime = f.sunsetTime
        self.precipProbability = f.precipProbability ?? -1
        self.precipType = f.precipType
        self.temperatureHigh = f.temperatureHigh ?? -1000
        self.temperatureLow = f.temperatureLow ?? -1000
        self.visibility = f.visibility ?? -1
        self.humidity = f.humidity ?? -1
        self.uvIndex = f.uvIndex ?? -1
        self.cloudCover = f.cloudCover ?? -1
        self.location = location
    }
}

struct ForecastUnmanaged {
    let time: Date
    let summary: String?
    let icon: String?
    let sunriseTime: Date?
    let sunsetTime: Date?
    let precipProbability: Float?
    let precipType: String?
    let temperatureHigh: Float?
    let temperatureLow: Float?
    let visibility: Float?
    let humidity: Float?
    let uvIndex: Float?
    let cloudCover: Float?
}

extension ForecastUnmanaged {
    static func parse(data: Data) -> [ForecastUnmanaged]? {
        var fullForecast = [ForecastUnmanaged]()
        
        guard let response = try? JSONSerialization.jsonObject(with: data, options: []) else {
            print("Couldn't convert response to json")
            return nil
        }
        guard let json = response as? JSONDictionary,
            let daily = json["daily"] as? JSONDictionary,
            let data = daily["data"] as? [JSONDictionary] else {
                print("Incorrect response format")
                return nil
        }
        for day in data {
            guard let time = day["time"] as? TimeInterval else {
                print("No time value in response.")
                return nil
            }
            let summary = day["summary"] as? String
            let icon = day["icon"] as? String
            let sunriseTime = day["sunriseTime"] as? TimeInterval
            let sunsetTime = day["sunsetTime"] as? TimeInterval
            let precipProbability = day["precipProbability"] as? NSNumber
            let precipType = day["precipType"] as? String
            let temperatureHigh = day["temperatureHigh"] as? NSNumber
            let temperatureLow = day["temperatureLow"] as? NSNumber
            let visibility = day["visibility"] as? NSNumber
            let humidity = day["humidity"] as? NSNumber
            let uvIndex = day["uvIndex"] as? NSNumber
            let cloudCover = day["cloudCover"] as? NSNumber

            let date = Date(timeIntervalSince1970: time)
            let sunrise = dateFromOptionalTime(sunriseTime)
            let sunset = dateFromOptionalTime(sunsetTime)

            fullForecast.append(ForecastUnmanaged(time: date, summary: summary, icon: icon, sunriseTime: sunrise, sunsetTime: sunset, precipProbability: precipProbability?.floatValue, precipType: precipType, temperatureHigh: temperatureHigh?.floatValue, temperatureLow: temperatureLow?.floatValue, visibility: visibility?.floatValue, humidity: humidity?.floatValue, uvIndex: uvIndex?.floatValue, cloudCover: cloudCover?.floatValue))
        }
        return fullForecast
    }
}

