//
//  Thermostat.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 12/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

protocol ThermostatObserver: class {
    func thermostat(currentThermostat: Thermostat, didUpdateProgramTargetTemperature temperature: Double)
}

class Thermostat: TimeManagerObserver, Observable {

    static let sharedInstance = Thermostat()
    var currentTemp: Double
    var targetTemp: Double
    var program: WeekProgram
    var customTarget: Bool = false
    var observers = [ThermostatObserver]()
    private var lastTarget: Double = 0

    init() {
        currentTemp = 15
        targetTemp = 15
        program = WeekProgram()

        TimeManager.sharedManager.addObserver(self)
    }

    func timeManager(manager: TimeManager, didUpdateToDate date: NSDate) {
        let newTargetTemp = program.getTemperatureForDate(date)
        if newTargetTemp != lastTarget {
            customTarget = false
            notifyObservers { (observer) -> Void in
                observer.thermostat(self, didUpdateProgramTargetTemperature: newTargetTemp)
            }
        }

        if !customTarget {
            targetTemp = newTargetTemp
            lastTarget = targetTemp
        }

        //hello, my name is Dirty Hack
        targetTemp = Double(round(10 * targetTemp) / 10)
        currentTemp = Double(round(10 * currentTemp) / 10)

        if currentTemp < targetTemp {
            currentTemp += 0.1
        } else if currentTemp > targetTemp {
            currentTemp -= 0.1
        }
    }

    //MARK: - Observable

    func addObserver(observer: ThermostatObserver) {
        self.observers.append(observer)
    }

    func removeObserver(observer: ThermostatObserver) {
        for i in 0..<observers.count {
            if observers[i] === observer {
                observers.removeAtIndex(i)
                break
            }
        }
    }

    internal func notifyObservers(notify: (observer: ThermostatObserver) -> Void) {
        for observer in observers {
            notify(observer: observer)
        }
    }
}

