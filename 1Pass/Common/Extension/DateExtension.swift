//
//  DateExtension.swift
//  ViPass
//
//  Created by Ngo Lien on 6/9/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation

extension Date {
    func utcString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConfig.DateTimeFormat
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: self)
    }
    
    //convert the UTC time to local time
    func toLocalTime() -> Date {
        let tz = NSTimeZone.default as NSTimeZone
        var seconds: Int? = nil
        seconds = tz.secondsFromGMT(for: self)
        return Date(timeInterval: TimeInterval(seconds ?? Int(0.0)), since: self)
    }
    
    //convert the local time to UTC time
    func toGlobalTime() -> Date {
        let tz = NSTimeZone.default as NSTimeZone
        var seconds: Int? = nil
        seconds = -tz.secondsFromGMT(for: self)
        return Date(timeInterval: TimeInterval(seconds ?? Int(0.0)), since: self)
    }

}
