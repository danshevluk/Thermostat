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
    @IBOutlet weak var temperatureStatusLabel: UILabel!
    @IBOutlet weak var targetTemeratureLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var temperatureStepper: UIStepper!
    @IBOutlet weak var resetToScheduleButton: UIButton!
    @IBOutlet weak var nextSwitchLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateCurrentDateLabels(TimeManager.sharedManager.currentDate())
        TimeManager.sharedManager.addObserver(self)
        Thermostat.sharedInstance.addObserver(self)

        temperatureStepper.minimumValue = 5.0
        temperatureStepper.maximumValue = 30.0
        temperatureStepper.stepValue = 0.1
        temperatureStepper.value = Thermostat.sharedInstance.targetTemp
        resetToScheduleButton.hidden = true
    }

    //MARK: - Buttons tap handlers

    @IBAction func changeTemperature(sender: AnyObject) {
        if let stepper = sender as? UIStepper {
            //dirty hack again
            let newTarget = Double(round(stepper.value * 10) / 10)
            resetToScheduleButton.hidden = false
            Thermostat.sharedInstance.customTarget = true
            Thermostat.sharedInstance.targetTemp = newTarget
            targetTemeratureLabel.text = "\(newTarget)"
            updateTemperatureStatus()
        }
    }

    @IBAction func resetToSchedule(sender: AnyObject) {
        Thermostat.sharedInstance.resetToScedule()
    }

    //MARK: - Update UI

    func updateCurrentDateLabels(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d"
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        currentDateLabels[0].text = dateFormatter.stringFromDate(date)
        currentDateLabels[1].text = timeFormatter.stringFromDate(date)
    }

    func updateNextSwitchLabels(date: NSDate) {
        if let nextSwitch = Thermostat.sharedInstance.program.getNextSwitch(date) {
            for label in nextSwitchLabels {
                label.hidden = false
            }
            nextSwitchLabel.text = formatSwitchToString(nextSwitch)
        } else {
            for label in nextSwitchLabels {
                label.hidden = true
            }
        }
    }

    func formatSwitchToString(nextSwitch: Switch) -> String {
        let time = nextSwitch.getHoursMinutes()
        let formatedHours = NSString.localizedStringWithFormat("%02d", time.hours) as String
        let formatedMinutes = NSString.localizedStringWithFormat("%02d", time.minutes) as String
        let type = nextSwitch.type == .Day ? "☀️" : "🌙"
        let tomorrow = nextSwitch.time == 0 ? "tomorrow " : ""

        return "\(type) \(tomorrow)at \(formatedHours):\(formatedMinutes)"
    }

    func updateTemperatureLabels() {
        targetTemeratureLabel.text = "\(Thermostat.sharedInstance.targetTemp)"
        currentTemperatureLabel.text = "\(Thermostat.sharedInstance.currentTemp)"
    }

    func updateTemperatureStatus() {
        let settings = (UIApplication.sharedApplication().delegate as! AppDelegate).settings
        if Thermostat.sharedInstance.targetTemp == settings.dayTemperature {
            temperatureStatusLabel.text = "☀️"
            resetToScheduleButton.hidden = true
        } else if Thermostat.sharedInstance.targetTemp == settings.nighTemperature {
            temperatureStatusLabel.text = "🌙"
//            resetToScheduleButton.hidden = true
        } else {
            temperatureStatusLabel.text = ""
        }
    }
    //MARK: - TimeManagerObserver

    func timeManager(manager: TimeManager, didUpdateToDate date: NSDate) {
        updateCurrentDateLabels(date)
        updateTemperatureLabels()
        updateNextSwitchLabels(date)
        updateTemperatureStatus()
    }

    //MARK: - ThermostatObserver

    func thermostat(currentThermostat: Thermostat, didUpdateProgramTargetTemperature temperature: Double) {
        temperatureStepper.value = temperature
        resetToScheduleButton.hidden = true
        timeManager(TimeManager.sharedManager, didUpdateToDate: TimeManager.sharedManager.currentDate())
    }
}

