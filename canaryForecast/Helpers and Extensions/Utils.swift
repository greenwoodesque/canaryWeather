//
//  Utils.swift
//  canaryForecast
//
//  Created by David Greenwood on 5/27/18.
//  Copyright © 2018 David Greenwood. All rights reserved.
//

import Foundation

protocol LocationSearcchDelegate: class {
    func switchLocationTo(latitude: Double, longitude: Double, locality: String)
}

extension Float {
    func roundedToString() -> String {
        return String(Int(self.rounded()))
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

func dateFromOptionalTime(_ time: TimeInterval?) -> Date? {
    if let time = time {
        return Date(timeIntervalSince1970: time)
    }
    return nil
}
