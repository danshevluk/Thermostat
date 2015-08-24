//
//  Thermostat.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 12/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

class Thermostat: TimeManagerObserver {

    static let sharedInstance = Thermostat()
    var currentTemp: Double
    var targetTemp: Double
    var program: WeekProgram

    init() {
        currentTemp = 15
        targetTemp = 15
        program = WeekProgram()

        TimeManager.sharedManager.addObserver(self)
    }

    func timeManager(manager: TimeManager, didUpdateToDate date: NSDate) {
        targetTemp = program.getTemperatureForDate(date)

        //hello, my name is Dirty Hack
        targetTemp = Double(round(10 * targetTemp) / 10)
        currentTemp = Double(round(10 * currentTemp) / 10)

        if currentTemp < targetTemp {
            currentTemp += 0.1
        } else if currentTemp > targetTemp {
            currentTemp -= 0.1
        }
    }
}
