//
//  TimeManager.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 12/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

protocol TimeManagerObserver: class {
     func timeManager(manager: TimeManager, didUpdateToDate date: NSDate)
}

class TimeManager: NSObject, Observable {

    static let sharedManager = TimeManager()
    private var startDate: NSDate
    private var actualStartDate: NSDate
    let multiplier = 300
    internal var observers = [TimeManagerObserver]()

    override init() {
        startDate = NSDate()
        actualStartDate = NSDate()

        super.init()
        NSTimer.scheduledTimerWithTimeInterval(0.2,
            target: self, selector: Selector("timerUpdate"), userInfo: nil, repeats: true)
    }

    func timerUpdate() {
        notifyObservers { (observer) -> Void in
            observer.timeManager(self, didUpdateToDate: self.currentDate())
        }
    }

    func currentDate() -> NSDate {
        var realDate = NSDate()
        let interval = abs(realDate.timeIntervalSinceDate(actualStartDate))
        let multipliedInterval = interval * Double(multiplier)

        return NSDate(timeInterval: multipliedInterval, sinceDate: startDate)
    }

    func setStartDate(date: NSDate) {
        startDate = date
        actualStartDate = NSDate()
    }

    // Observer pattern
    func addObserver(observer: TimeManagerObserver) {
        self.observers.append(observer)
    }

    func removeObserver(observer: TimeManagerObserver) {
        for i in 0..<observers.count {
            if observers[i] === observer {
                observers.removeAtIndex(i)
                break
            }
        }
    }

    internal func notifyObservers(notify: (observer: TimeManagerObserver) -> Void) {
        for observer in observers {
            notify(observer: observer)
        }
    }
}
