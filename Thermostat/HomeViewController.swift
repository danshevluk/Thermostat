//
//  HomeViewController.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 15/07/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, TimeManagerObserver, ThermostatObserver {

    @IBOutlet var nextSwitchLabels: [UILabel]!
    @IBOutlet var currentDateLabels: [UILabel]!
    @IBOutlet weak var temepatureStatusLabel: UILabel!
    @IBOutlet weak var targetTemeratureLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var temperatureStepper: UIStepper!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateCurrentDateLabels(TimeManager.sharedManager.currentDate())
        TimeManager.sharedManager.addObserver(self)
        Thermostat.sharedInstance.addObserver(self)

        temperatureStepper.minimumValue = 5.0
        temperatureStepper.maximumValue = 30.0
        temperatureStepper.stepValue = 0.1
        temperatureStepper.value = Thermostat.sharedInstance.targetTemp
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

    @IBAction func changeTemperature(sender: AnyObject) {
        if let stepper = sender as? UIStepper {
            //dirty hack again
            let newTarget = Double(round(stepper.value * 10) / 10)
            Thermostat.sharedInstance.customTarget = true
            Thermostat.sharedInstance.targetTemp = newTarget
            targetTemeratureLabel.text = "\(newTarget)"
        }
    }

    //MARK: - TimeManagerObserver

    func timeManager(manager: TimeManager, didUpdateToDate date: NSDate) {
        updateCurrentDateLabels(date)
        updateTemperatureLabels()
        updateNextSwitchLabels(date)
    }

    //MARK: - ThermostatObserver

    func thermostat(currentThermostat: Thermostat, didUpdateProgramTargetTemperature temperature: Double) {
        temperatureStepper.value = temperature
    }
}

