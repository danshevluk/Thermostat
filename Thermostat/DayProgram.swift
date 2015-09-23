//
//  DayProgram.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 12/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

enum SwitchIncertStatus {
    case IdenticalSwitches
    case AmountLimitaionViolated
    case DoesNotMakeSence
    case Ok
    case Error
}

@objc class DayProgram: NSObject, NSCoding, NSCopying {
    var switches: [Switch]

    override init() {
        switches = [Switch()]
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        switches = aDecoder.decodeObjectForKey("switches") as! [Switch]
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(switches, forKey: "switches")
    }

    func tryToAddSwitch(tempSwitch: Switch) -> SwitchIncertStatus {
        if switches.first!.type == .Day && switches.count > 10 {
            return .AmountLimitaionViolated
        } else if switches.first!.type == .Night && switches.count > 11 {
            return .AmountLimitaionViolated
        }

        for sw in switches {
            if sw.time == tempSwitch.time {
                return .IdenticalSwitches
            }
        }
        switches.append(tempSwitch)

        switches.sortInPlace { $0.time < $1.time }
        if let indexOfNewSwitch = switches.indexOf(tempSwitch) {
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

            return .Ok
        }

        return .Error
    }

    func tryToAddInterval(interval: Interval) -> SwitchIncertStatus {
        if switches.first!.type == .Day && switches.count > 9 {
            return .AmountLimitaionViolated
        } else if switches.first!.type == .Night && switches.count > 10 {
            return .AmountLimitaionViolated
        }

        if interval.start.time == interval.end.time {
            return .IdenticalSwitches
        } else if interval.start.time > interval.end.time ||
                interval.start.type == interval.end.type {
            return .Error
        }

        for sw in switches {
            if sw.time == interval.start.time  {
                return .IdenticalSwitches
            }
        }

        switches.append(interval.start)
        switches.sortInPlace { $0.time < $1.time }

        if let indexOfNewSwitch = switches.indexOf(interval.start) {
            if indexOfNewSwitch == 0 {
                fatalError("omg wtf")
            }

            if switches[indexOfNewSwitch - 1].type == interval.start.type {
                switches.removeAtIndex(indexOfNewSwitch)
                return .DoesNotMakeSence
            } else {
                var intervalEndIndex = -1
                for var i = indexOfNewSwitch + 1; i < switches.count; i++ {
                    if switches[i].time < interval.end.time {
                        intervalEndIndex = i
                    }
                }

                if intervalEndIndex > 0 {
                    switches.removeRange(Range(start: indexOfNewSwitch + 1, end: intervalEndIndex+1))
                }

                switches.append(interval.end)
                switches.sortInPlace { $0.time < $1.time }

                return .Ok
            }
        }

        return .Error
    }

    func changeFirstSwitchType(type: SwitchType) -> Bool {
        if let firstSwitch = switches.first {
            firstSwitch.type = type
            if switches.count > 1 && switches[1].type == type {
                switches.removeAtIndex(1)
            }
            return true
        }

        return false
    }

    func deleteSwitchAtIndex(index: Int) -> [Int] {
        var deletedIndexes: [Int] = []
        if index + 1 < switches.count {
            switches.removeAtIndex(index + 1)
            deletedIndexes.append(index + 1)
        }

        deletedIndexes.append(index)
        switches.removeAtIndex(index)

        return deletedIndexes
    }

    func getTemperature(hours: Int, minutes: Int) -> SwitchType {
        let time = hours * 60 + minutes
        return getTemperature(time)
    }

    func getTemperature(time: Int) -> SwitchType {
        var switchType = SwitchType.Night

        for (index, _) in switches.enumerate()
            where switches[index].time < time {
              switchType = switches[index].type
        }

        return switchType
    }

    func getNextSwitch(hours hours: Int, minutes: Int) -> Switch? {
        let time = hours * 60 + minutes
        return getNextSwitch(time)
    }

    private func getNextSwitch(time: Int) -> Switch? {
        for sw in switches where  time < sw.time {
            return sw
        }

        return nil
    }

    //MARK: - NSCopying

    func copyWithZone(zone: NSZone) -> AnyObject {
        let programCopy = DayProgram()
        programCopy.switches.removeAll(keepCapacity: true)
        for sw in switches {
            programCopy.switches.append(sw.copy() as! Switch)
        }

        return programCopy
    }
}