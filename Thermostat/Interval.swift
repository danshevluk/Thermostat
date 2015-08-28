//
//  Interval.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 28/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

struct Interval {
    var start: Switch
    var end: Switch

    init() {
        start = Switch()
        end = Switch()
    }

    init(start: Switch, end: Switch) {
        self.start = start
        self.end = end
    }
}
