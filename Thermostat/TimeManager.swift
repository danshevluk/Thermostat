//
//  TimeManager.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 12/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

class TimeManager: NSObject {

    static let sharedManager: TimeManager = TimeManager()
    private var startDate: NSDate
    let multiplier = 300

    override init() {
        startDate = NSDate()
        super.init()
    }

    func currentDate() -> NSDate {
        var realDate = NSDate()
        let interval = realDate.timeIntervalSinceDate(startDate)
        let multipliedInterval = interval * Double(multiplier)

        return NSDate(timeInterval: multipliedInterval, sinceDate: startDate)
    }

    func setStartDate(date: NSDate) {
        startDate = date
    }
   
}
