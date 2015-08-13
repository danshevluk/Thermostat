//
//  DayProgram.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 12/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

enum SwitchType: Int {
    case Day
    case Night
}

@objc class Switch: NSObject, NSCoding {

    var hours: Int
    var minutes: Int
    var type: SwitchType

    init(hours: Int, minutes: Int, type: SwitchType) {
        self.hours = hours
        self.minutes = minutes
        self.type = type
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        hours = aDecoder.decodeIntegerForKey("hours")
        minutes = aDecoder.decodeIntegerForKey("minutes")
        type = SwitchType(rawValue: aDecoder.decodeIntegerForKey("type"))!
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(hours, forKey: "hours")
        aCoder.encodeInteger(minutes, forKey: "minutes")
        aCoder.encodeInteger(type.rawValue, forKey: "type")
    }
}

@objc class DayProgram: NSObject, NSCoding {
    var switches: [Switch]

    override init() {
        switches = []
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        println("Decode day")
        switches = aDecoder.decodeObjectForKey("switches") as! [Switch]
    }

    func encodeWithCoder(aCoder: NSCoder) {
        println("Encode day")
        aCoder.encodeObject(switches, forKey: "switches")
    }

    func tryToAddSwitch(tempSwitch: Switch) -> Bool {
        if switches.count > 10 {
            return false
        }

        switches.append(tempSwitch)
        return true
    }
}
