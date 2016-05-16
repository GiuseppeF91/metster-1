//
//  Users.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/31/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//
import UIKit
extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy/MM/dd hh:mm:ss"
        let d = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval:0, sinceDate:d)
    }
    
    static func dateFromMilliseconds(ms: String) -> NSDate {
        return NSDate(timeIntervalSince1970:Double(ms)!)
    }
    
    func dayOfWeek() -> String? {
        guard
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = cal.components(.Weekday, fromDate: self) else {return nil}
        
        let weekDay =  comp.weekday
        
        switch weekDay {
        case 1:
            return "Sunday"
            
        case 2:
            return "Monday"
            
        case 3:
            return "Tuesday"
            
        case 4:
            return "Wednesday"
            
        case 5:
            return "Thursday"
            
        case 6:
            return "Friday"
            
        case 7:
            return "Saturday"
            
        default:
            print("Error fetching days")
            return "Day"
        }
        
        
        
    }
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date:NSDate) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
    
    static func dateDiff(dateStr:String) -> String {
        let f:NSDateFormatter = NSDateFormatter()
        f.timeZone = NSTimeZone.localTimeZone()
        f.dateFormat = "yyyy-M-dd'T'HH:mm:ss.SSSZZZ"
        
        let now = f.stringFromDate(NSDate())
        let startDate = NSDate(timeIntervalSince1970:Double(dateStr)!)
        let endDate = f.dateFromString(now)
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        
        let dateComponents = calendar.components([.WeekOfMonth, .Day, .Hour, .Minute, .Second], fromDate: startDate, toDate: endDate!, options: [])
        
        let weeks = abs(dateComponents.weekOfMonth)
        let days = abs(dateComponents.day)
        let hours = abs(dateComponents.hour)
        let min = abs(dateComponents.minute)
        let sec = abs(dateComponents.second)
        
        var timeAgo = ""
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        timeAgo = dateFormatter.stringFromDate(startDate)
    
        
        if (days > 0 ) {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM"
            timeAgo = dateFormatter.stringFromDate(startDate)
        }
        
        
        print("timeAgo is===> \(timeAgo)")
        return timeAgo;
    }
    
}