//
//  DayProgram.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 12/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

enum SwitchIncertStatus: Int {
    case IdenticalSwitches
    case AmountLimitaionViolated
    case DoesNotMakeSence
    case Ok
    case Error
}

@objc class DayProgram: NSObject, NSCoding {
    var switches: [Switch]

    override init() {
        switches = [Switch()]
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

    func tryToAddSwitch(tempSwitch: Switch) -> SwitchIncertStatus {
        if switches.count > 10 {
            return .AmountLimitaionViolated
        }

        for sw in switches {
            if sw.time == tempSwitch.time {
                return .IdenticalSwitches
            }
        }
        switches.append(tempSwitch)

        switches.sort { $0.time < $1.time }
        if let indexOfNewSwitch = find(switches, tempSwitch) {
            if indexOfNewSwitch == 0 {
                fatalError("omg wtf")
            }

            if switches[indexOfNewSwitch - 1].type == tempSwitch.type {
                switches.removeAtIndex(indexOfNewSwitch)
                return .DoesNotMakeSence
            } else if indexOfNewSwitch != switches.count - 1 &&
                switches[indexOfNewSwitch + 1].type == tempSwitch.type {
                switches.removeAtIndex(indexOfNewSwitch + 1)
                return .Ok
            }
        }

        return .Error
    }

    func getTemperature(hours: Int, minutes: Int) -> SwitchType {
        let time = hours * 60 + minutes
        return getTemperature(time)
    }

    func getTemperature(time: Int) -> SwitchType {
        for var i = 0; i < switches.count; i++ {
            if switches[i].time > time {
                return switches[i-1].type
            }
        }

        return .Night
    }
}







