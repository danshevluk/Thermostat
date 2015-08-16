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

    override func viewDidLoad() {
        super.viewDidLoad()
        if let lastSwitch = dayProgram?.switches.last {
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
            case .Error:
                println("You dumb")
            case .IdenticalSwitches:
                println("Idential switches")
            case .Ok:
                if let delegate = self.delegate {
                    delegate.newSwitch(self, didCreateNewSwitch: newSwitch)
                }

                dismissViewControllerAnimated(true, completion: nil)
            default:
                fatalError("You've done somethind really bad")
            }
        } else {
            println("weekProgram doesn't set")
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
