//
//  WeekProgram.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 12/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

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
        days = aDecoder.decodeObjectForKey("days") as! [DayProgram]

    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(days, forKey: "days")
    }

    func tryToAddSwitchForDay(tempSwitch: Switch, forDay day: Weekday) -> SwitchIncertStatus {
        return days[day.rawValue].tryToAddSwitch(tempSwitch)
    }

    func getTemperatureForDate(date: NSDate) -> Double {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)

        if let dateComp = calendar?.components(.WeekdayCalendarUnit | .HourCalendarUnit | .MinuteCalendarUnit, fromDate: date) {
            // FIXME: I HAVE NO IDEA WHY THIS WORKS
            let dayProgram = days[dateComp.weekday - 1]
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
