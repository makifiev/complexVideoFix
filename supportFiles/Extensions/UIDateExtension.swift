//
//  DateExtension.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 03.08.2021.
//

import Foundation
import UIKit

enum Interval: Int
{
    case DayInterval = 0
    case WeekInterval = 1
    case MonthInterval = 2
}

extension Date
{
    static func stringFromDate(dateString: String, formats: NSArray, enLocale: Bool) -> String
    {
        if dateString.count == 0
        {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formats[0] as? String
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if enLocale
        {
            dateFormatter.locale = Locale(identifier: "en_US")
        }
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = formats[1] as? String
        let string = dateFormatter.string(from: date!)
        if string.count == 0
        {
            return ""
        }
        return string
    }
    
    static func stringFromDate(date:Date, pattern:String) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        formatter.locale = Locale(identifier: "ru")
        
        return formatter.string(from: date)
    }
    
    static func dateFromString(dateString: String, pattern: String, enLocale: Bool) -> Date?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern
        if enLocale {
            dateFormatter.locale = Locale.init(identifier: "en_US")
        }
        dateFormatter.locale = Locale.init(identifier: "ru_RU")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let date = dateFormatter.date(from: dateString) ?? Date()
        
        return date
    }
    static func dateFromDate(date: Date, interval: Interval) -> Date
    {
        let day = interval == Interval.DayInterval ? -1 : interval == Interval.WeekInterval ? -7 : -30
        return Date.dateFromDate(date: date, day: day, hour: 0)
    }
    
    static func dateFromDate(date: Date, day: Int, hour: Int) -> Date
    {
        var dayComponent = DateComponents()
        if day != 0
        {
            dayComponent.day = day
        }
        if hour != 0
        {
            dayComponent.hour = hour
        }
        return Calendar.current.date(byAdding: dayComponent, to: date)!
    }
}
