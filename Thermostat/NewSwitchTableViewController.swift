//
//  NewSwitchTableViewController.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 14/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

protocol NewSwitchTableViewControllerDelegate: NSObjectProtocol {
    func newSwitch(contoller: NewSwitchTableViewController, didCreateNewSwitch newSwitch: Switch)
}

enum NewSwitchTableViewControllerState {
    case Edit
    case Create
}

class NewSwitchTableViewController: UITableViewController {

    var delegate: NewSwitchTableViewControllerDelegate?

    @IBOutlet weak var switchTypeConrol: UISegmentedControl!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var intervalSwitch: UISwitch!
    @IBOutlet weak var intervalEndTimePicker: UIDatePicker!
    @IBOutlet weak var intervalEndPickerCell: UITableViewCell!
    @IBOutlet weak var intervalSwitchCell: UITableViewCell!
    
    var state: NewSwitchTableViewControllerState!
    var dayProgram: DayProgram?
    var newSwitch: Switch?

    override func viewDidLoad() {
        super.viewDidLoad()

        intervalEndPickerCell.hidden = true

        if state == .Edit {
            intervalSwitchCell.hidden = true
            if let sw = newSwitch {
                let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                let components = calendar.components(.HourCalendarUnit | .MinuteCalendarUnit, fromDate: NSDate())
                let timeComponents = sw.getHoursMinutes()
                components.minute = timeComponents.minutes
                components.hour = timeComponents.hours
                if let date = calendar.dateFromComponents(components) {
                    timePicker.date = date
                }

                switchTypeConrol.selectedSegmentIndex = sw.type.rawValue
            }
        } else if state == .Create {
            if let lastSwitch = dayProgram?.switches.last {
                if lastSwitch.type == .Day {
                    switchTypeConrol.selectedSegmentIndex = 1
                } else {
                    switchTypeConrol.selectedSegmentIndex = 0
                }

                timePicker.date = lastSwitch.getDateByAddingMinutes(60)
                updateIntervalEndTimePickerWithIntervalStartDate(timePicker.date)
            }
        }
    }

    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    @IBAction func save(sender: AnyObject) {
        let tmp = self.newSwitch

        if let sw = self.newSwitch {
            for var i = 0; i < dayProgram!.switches.count; i++ {
                if dayProgram!.switches[i] == sw {
                    dayProgram!.switches.removeAtIndex(i)
                    break
                }
            }
        }

        let calendar = NSCalendar.currentCalendar()
        let dateComp = calendar.components(
            .HourCalendarUnit | .MinuteCalendarUnit, fromDate: timePicker.date)
        let switchType = SwitchType(rawValue: switchTypeConrol.selectedSegmentIndex)!
        let newSwitch = Switch(hours: dateComp.hour, minutes: dateComp.minute, type: switchType)

        if let program = dayProgram {
            if intervalSwitch.on {
                let intervalEndType: SwitchType = switchType == .Day ? .Night : .Day
                let intervalEndDateComp = calendar.components(
                    .HourCalendarUnit | .MinuteCalendarUnit, fromDate: intervalEndTimePicker.date)
                let intervalEnd = Switch(hours: intervalEndDateComp.hour, minutes: intervalEndDateComp.minute, type: intervalEndType)

                let alert: UIAlertController
                switch program.tryToAddInterval(Interval(start: newSwitch, end: intervalEnd)) {
                case .Error:
                    showErrorAlertWithMessage("You can't add this interval!")
                case .AmountLimitaionViolated:
                    showErrorAlertWithMessage("You can't add more than 10 switches per day")
                case .IdenticalSwitches:
                    showErrorAlertWithMessage("One of interval edges matches with another switch.")
                case .Ok:
                    if let delegate = self.delegate {
                        delegate.newSwitch(self, didCreateNewSwitch: newSwitch)
                    }
                    dismissViewControllerAnimated(true, completion: nil)
                case .DoesNotMakeSence:
                    println("Does not make sence")
                    let type = newSwitch.type == .Day ? "day" : "night"
                    showErrorAlertWithMessage("Begining of your interval does not change temperature at all. It's already \(type) at this time.")
                default:
                    fatalError("I'm not gonna kill you. I just gonna hurt you. Really, really bad")
                }
            } else {
                let alert: UIAlertController
                switch program.tryToAddSwitch(newSwitch) {
                case .AmountLimitaionViolated:
                    showErrorAlertWithMessage("You can't add more than 10 switches per day")
                case .DoesNotMakeSence:
                    if let oldSwitch = tmp {
                        program.tryToAddSwitch(oldSwitch)
                    }
                    let type = newSwitch.type == .Day ? "day" : "night"
                    showErrorAlertWithMessage("You switch does not change anything. It's alredy \(type) at this time. Change switch type to fix this problem.")
                case .Error:
                    if let oldSwitch = tmp {
                        program.tryToAddSwitch(oldSwitch)
                    }
                    showErrorAlertWithMessage("You can't create this switch.")
                case .IdenticalSwitches:
                    println("Idential switches")
                    if let oldSwitch = tmp {
                        program.tryToAddSwitch(oldSwitch)
                    }
                    showErrorAlertWithMessage("You can't add identical switches.")
                case .Ok:
                    if let delegate = self.delegate {
                        delegate.newSwitch(self, didCreateNewSwitch: newSwitch)
                    }

                    dismissViewControllerAnimated(true, completion: nil)
                default:
                    fatalError("You've done somethind really bad")
                }
            }
        } else {
            fatalError("You've done somethind really bad")
        }
    }

    func showErrorAlertWithMessage(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func timePickerValueChanged(sender: AnyObject) {
        if let picker = sender as? UIDatePicker where state == .Create {
            updateIntervalEndTimePickerWithIntervalStartDate(picker.date)
        }
    }

    func updateIntervalEndTimePickerWithIntervalStartDate(date: NSDate) {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components = calendar.components(.HourCalendarUnit | .MinuteCalendarUnit, fromDate: date)
        if components.hour == 23 {
            components.minute = 59
            intervalEndTimePicker.date = calendar.dateFromComponents(components)!
        } else {
            intervalEndTimePicker.date = date.dateByAddingTimeInterval(60 * 60)
        }
    }

    @IBAction func createIntervalSwitchChanged(sender: AnyObject) {
        if let intervalSwitch = sender as? UISwitch {
            UIView.transitionWithView(intervalEndPickerCell, duration: 0.3,
                options: .TransitionCrossDissolve,
                animations: { () -> Void in
                    self.intervalEndPickerCell.hidden = !intervalSwitch.on
            }, completion: { (finished) -> Void in
                if finished {
                    let indexPath = NSIndexPath(forRow: 1, inSection: 1)
                    self.tableView.scrollToRowAtIndexPath(indexPath,
                        atScrollPosition: .Bottom, animated: true)
                }
            })
        }
    }
}
