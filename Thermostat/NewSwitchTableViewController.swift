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
                    showErrorAlertWithMessage("The switch is invalid.")
                case .AmountLimitaionViolated:
                    showErrorAlertWithMessage("You cannot add more than 10 switches a day.")
                case .IdenticalSwitches:
                    showErrorAlertWithMessage("The switch is identical to the existing one.")
                case .Ok:
                    if let delegate = self.delegate {
                        delegate.newSwitch(self, didCreateNewSwitch: newSwitch)
                    }
                    dismissViewControllerAnimated(true, completion: nil)
                case .DoesNotMakeSence:
                    let type = newSwitch.type == .Day ? "day" : "night"
                    showErrorAlertWithMessage("The switch will not have any effect on the temperature. It would already be \(type) by that time.")
                default:
                    fatalError("SOUP")
                }
            } else {
                let alert: UIAlertController
                switch program.tryToAddSwitch(newSwitch) {
                case .AmountLimitaionViolated:
                    showErrorAlertWithMessage("You cannot add more than 10 switches per day.")
                case .DoesNotMakeSence:
                    if let oldSwitch = tmp {
                        program.tryToAddSwitch(oldSwitch)
                    }
                    let type = newSwitch.type == .Day ? "day" : "night"
                    showErrorAlertWithMessage("The switch will not have any effect on the temperature. It would already be \(type) by that time.")
                case .Error:
                    if let oldSwitch = tmp {
                        program.tryToAddSwitch(oldSwitch)
                    }
                    showErrorAlertWithMessage("The switch is invalid.")
                case .IdenticalSwitches:
                    if let oldSwitch = tmp {
                        program.tryToAddSwitch(oldSwitch)
                    }
                    showErrorAlertWithMessage("The switch is identical to the existing one.")
                case .Ok:
                    if let delegate = self.delegate {
                        delegate.newSwitch(self, didCreateNewSwitch: newSwitch)
                    }

                    dismissViewControllerAnimated(true, completion: nil)
                default:
                    fatalError("CROP")
                }
            }
        } else {
            fatalError("ALLE")
        }
    }

    func showErrorAlertWithMessage(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
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
