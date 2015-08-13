//
//  WeekProgram.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 12/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

enum WeekDay: Int {
    case Sunday = 1
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
}

@objc class WeekProgram: NSObject, NSCoding {

    var days: [DayProgram] = []
    var a = 9

    override init() {
        for i in 0..<7 {
            days.append(DayProgram())
        }

        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        println("Decode week")
        days = aDecoder.decodeObjectForKey("days") as! [DayProgram]

    }

    func encodeWithCoder(aCoder: NSCoder) {
        println("Encode week")
        aCoder.encodeObject(days, forKey: "days")
    }

    func tryToAddSwitchForDay(tempSwitch: Switch, forDay day: WeekDay) -> SwitchIncertStatus {
        return days[day.rawValue].tryToAddSwitch(tempSwitch)
    }

    func getTemperatureForDate(date: NSDate) -> Double {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        if let dateComp = calendar?.components(.WeekdayCalendarUnit | .HourCalendarUnit | .MinuteCalendarUnit, fromDate: date) {
            let dayProgram = days[dateComp.weekday]
            let tempType = dayProgram.getTemperature(dateComp.hour, minutes: dateComp.minute)
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                if tempType == .Day {
                    return appDelegate.settings.dayTemperature
                } else {
                    return appDelegate.settings.nighTemperature
                }
            }
        }

        return 15
    }
}
