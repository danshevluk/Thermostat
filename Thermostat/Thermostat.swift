//
//  Thermostat.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 12/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

//Thermostat emulator
class Thermostat: NSObject {
    var currentTemp: Double
    var targetTemp: Double
    var program: WeekProgram

    override init() {
        currentTemp = 15
        targetTemp = 15
        program = WeekProgram()

        super.init()

        NSTimer.scheduledTimerWithTimeInterval(2, target: self,
            selector: "timerUpdate", userInfo: nil, repeats: true)
    }

    func timerUpdate() {
        let currentDate = TimeManager.sharedManager.currentDate()
        targetTemp = program.getTemperatureForDate(currentDate)

        if currentTemp < targetTemp {
            currentTemp += 0.1
        } else if currentTemp > targetTemp {
            currentTemp -= 0.1
        }
    }
}
