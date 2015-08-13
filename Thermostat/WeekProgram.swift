//
//  WeekProgram.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 12/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

enum WeekDay: Int {
    case Monday = 0
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
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

    func tryToAddSwitchForDay(tempSwitch: Switch, forDay day: WeekDay) -> Bool {
        if days[day.rawValue].tryToAddSwitch(tempSwitch) {
            return true
        }

        return false
    }
}
