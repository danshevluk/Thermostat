//
//  HomeViewController.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 15/07/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, TimeManagerObserver {

    @IBOutlet var nextSwitchLabels: [UILabel]!
    @IBOutlet var currentDateLabels: [UILabel]!
    @IBOutlet weak var temepatureStatusLabel: UILabel!
    @IBOutlet weak var targetTemeratureLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateCurrentDateLabels(TimeManager.sharedManager.currentDate())
        TimeManager.sharedManager.addObserver(self)
//        //Test test test
//        let weekProgram = WeekProgram()
//        println(weekProgram)
//        let data = NSKeyedArchiver.archivedDataWithRootObject(weekProgram)
//        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "weekProgram")
//        let wpData = NSUserDefaults.standardUserDefaults().objectForKey("weekProgram") as! NSData
//        let wp = NSKeyedUnarchiver.unarchiveObjectWithData(wpData) as! WeekProgram
//        println(wp)
    }

    func updateCurrentDateLabels(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d"
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "hh:mm a"

        currentDateLabels[0].text = dateFormatter.stringFromDate(date)
        currentDateLabels[1].text = timeFormatter.stringFromDate(date)
    }

    func updateNextSwitchLabels(date: NSDate) {

    }

    func updateTemperatureLabels() {
        targetTemeratureLabel.text = "\(Thermostat.sharedInstance.targetTemp)"
        currentTemperatureLabel.text = "\(Thermostat.sharedInstance.currentTemp)"
    }

    //MARK: - TimeManagerObserver

    func timeManager(manager: TimeManager, didUpdateToDate date: NSDate) {
        updateCurrentDateLabels(date)
        updateTemperatureLabels()
        updateNextSwitchLabels(date)
    }
}

