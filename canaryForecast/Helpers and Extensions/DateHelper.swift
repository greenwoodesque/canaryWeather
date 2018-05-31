//
//  DateHelper.swift
//  canaryForecast
//
//  Created by David Greenwood on 5/27/18.
//  Copyright © 2018 David Greenwood. All rights reserved.
//

import Foundation

class DateHelper {
    
    static let shared = DateHelper()
    
    private let df: DateFormatter
    private let tf: DateFormatter
    
    private init() {
        df = DateFormatter()
        tf = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("EEE MMM dd, yy")
        tf.dateStyle = .none
        tf.timeStyle = .medium
    }
    
    func formattedDate(_ date: Date) -> String {
        return df.string(from: date)
    }
    
    func formattedTime(_ time: Date) -> String {
        return tf.string(from: time)
    }
}
