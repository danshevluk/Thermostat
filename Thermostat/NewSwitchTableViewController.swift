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

class NewSwitchTableViewController: UITableViewController {

    var delegate: NewSwitchTableViewControllerDelegate?
    @IBOutlet weak var switchTypeConrol: UISegmentedControl!
    @IBOutlet weak var timePicker: UIDatePicker!
    var dayProgram: DayProgram?
    var newSwitch: Switch?
    @IBOutlet weak var intervalEndPickerCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()


        intervalEndPickerCell.hidden = true

        if let sw = newSwitch {
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components(.HourCalendarUnit | .MinuteCalendarUnit, fromDate: NSDate())
            let timeComponents = sw.getHoursMinutes()
            components.minute = timeComponents.minutes
            components.hour = timeComponents.hours
            if let date = calendar.dateFromComponents(components) {
                timePicker.date = date
            }

            switchTypeConrol.selectedSegmentIndex = sw.type.rawValue
        } else if let lastSwitch = dayProgram?.switches.last {
            if lastSwitch.type == .Day {
                switchTypeConrol.selectedSegmentIndex = 1
            } else {
                switchTypeConrol.selectedSegmentIndex = 0
            }

            timePicker.date = lastSwitch.getDateByAddingMinutes(15)
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
            switch program.tryToAddSwitch(newSwitch) {
            case .AmountLimitaionViolated:
                println("Shit! amount limitation violated")
            case .DoesNotMakeSence:
                println("Shit! Your switch doesn't make sence")
                if let oldSwitch = tmp {
                    program.tryToAddSwitch(oldSwitch)
                }
            case .Error:
                println("You dumb")
                if let oldSwitch = tmp {
                    program.tryToAddSwitch(oldSwitch)
                }
            case .IdenticalSwitches:
                println("Idential switches")
                if let oldSwitch = tmp {
                    program.tryToAddSwitch(oldSwitch)
                }
            case .Ok:
                if let delegate = self.delegate {
                    delegate.newSwitch(self, didCreateNewSwitch: newSwitch)
                }

                dismissViewControllerAnimated(true, completion: nil)
            default:
                fatalError("You've done somethind really bad")
                if let oldSwitch = tmp {
                    program.tryToAddSwitch(oldSwitch)
                }
            }
        } else {
            println("weekProgram doesn't set")
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func createIntervalSwitchChanged(sender: AnyObject) {
        if let intervalSwitch = sender as? UISwitch {
            UIView.transitionWithView(intervalEndPickerCell, duration: 0.3,
                options: UIViewAnimationOptions.TransitionCrossDissolve,
                animations: { () -> Void in
                    self.intervalEndPickerCell.hidden = !intervalSwitch.on
            }, completion: nil)
        }
    }
}
