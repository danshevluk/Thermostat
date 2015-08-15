//
//  Switch.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 13/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

enum SwitchType: Int {
    case Day
    case Night
}

@objc class Switch: NSObject, NSCoding {

    var time: Int
    var type: SwitchType

    override init() {
        self.time = 0
        self.type = .Night
        super.init()
    }

    init(hours: Int, minutes: Int, type: SwitchType) {
        self.time = hours * 60 + minutes
        self.type = type
        super.init()
    }

    func getHoursMinutes() -> (hours: Int, minutes: Int) {
        var hours: Int = time / 60
        var minutes: Int = time - hours * 60

        return (hours, minutes)
    }

    //MARK: - NSCoding stuff

    required init(coder aDecoder: NSCoder) {
        time = aDecoder.decodeIntegerForKey("time")
        type = SwitchType(rawValue: aDecoder.decodeIntegerForKey("type"))!
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(time, forKey: "time")
        aCoder.encodeInteger(type.rawValue, forKey: "type")
    }
}

