//
//  DayViewController.swift
//  Thermostat
//
//  Created by Dan K. on 2015-08-14.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

class DayViewController: UITableViewController, NewSwitchTableViewControllerDelegate {
    
    var dayProgram: DayProgram!
    var dayOfTheWeek: Int!

    var copyButtonItem: UIBarButtonItem!
    var addSwitchButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        copyButtonItem = UIBarButtonItem(title: "Copy",
            style: .Plain, target: self, action: "copySwitches:")
        addSwitchButtonItem = UIBarButtonItem(barButtonSystemItem: .Add,
            target: self, action: "addNewSwitch:")
        navigationItem.rightBarButtonItems = rightBarButtons()
        
        // Load the program of the selected weekday
        dayProgram = Thermostat.sharedInstance.program.days[dayOfTheWeek]
    }

    override func viewWillDisappear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.saveWeekProgram(Thermostat.sharedInstance.program)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1. Start with day (night)
        // 2. Switches
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return dayProgram.switches.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("StartCell",
                    forIndexPath: indexPath) as! UITableViewCell
        } else {
            let switchModel = dayProgram.switches[indexPath.row]
            cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell",
                    forIndexPath: indexPath) as! UITableViewCell

            let time = switchModel.getHoursMinutes()
            if let switchTimeLabel = cell.viewWithTag(1) as? UILabel,
                    tempIndicator = cell.viewWithTag(2) as? UILabel {
                if switchModel.type == .Day {
                    switchTimeLabel.text =  formatTimeToString(time)
                    tempIndicator.text = "☀️"
                } else {
                    switchTimeLabel.text = formatTimeToString(time)
                    tempIndicator.text = "🌙"
                }
            }
        }

        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let deletedIndexes = dayProgram.deleteSwitchAtIndex(indexPath.row)
        var indexPaths: [NSIndexPath] = []
        for i in deletedIndexes {
            let newIndexPath = NSIndexPath(forRow: i, inSection: indexPath.section)
            indexPaths.append(newIndexPath)
        }

        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Left)
    }

    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Start with"
        } else {
            return "Switches"
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 {
            return nil
        } else {
            return indexPath
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
           let alert = UIAlertController(title: "Warning", message: "For correct thermostat work you should start any day with a day or a night temperature. Check out switcher above.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier("addSwitch", sender: dayProgram.switches[indexPath.row])
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        let switchDuration = 0.4
        UIView.animateWithDuration(switchDuration, animations: { () -> Void in
            if editing {
                self.navigationItem.rightBarButtonItems = [self.editButtonItem()]
            } else {
                self.navigationItem.rightBarButtonItems = self.rightBarButtons()
            }
        })
    }

    @IBAction func dayStartsControlChanged(sender: AnyObject) {
        if let control =  sender as? UISegmentedControl {
            if let type = SwitchType(rawValue: control.selectedSegmentIndex) {
                dayProgram.changeFirstSwitchType(type)
                tableView.reloadData()
            }
        }
    }

    // MARK: - BarButtonItem handlers

    func addNewSwitch(sender: AnyObject) {
        performSegueWithIdentifier("addSwitch", sender: dayProgram)
    }

    func copySwitches(sender: AnyObject) {
        performSegueWithIdentifier("copySchedule", sender: self)
    }

    //MARK: - Tools

    func rightBarButtons() -> [UIBarButtonItem] {
        return [self.addSwitchButtonItem, self.editButtonItem(), self.copyButtonItem]
    }

    func formatTimeToString(time: (hours: Int, minutes: Int)) -> String {
        let formatedHours = NSString.localizedStringWithFormat("%02d", time.hours) as String
        let formatedMinutes = NSString.localizedStringWithFormat("%02d", time.minutes) as String

        return formatedHours + ":" + formatedMinutes
    }

    //MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier,
            nvc = segue.destinationViewController as? UINavigationController {
            switch identifier {
            case "addSwitch":
                if let dvc = nvc.viewControllers.first as? NewSwitchTableViewController {
                    dvc.delegate = self
                    dvc.dayProgram = dayProgram
                    if let aSwitch = sender as? Switch {
                        dvc.state = .Edit
                        dvc.newSwitch = aSwitch
                    } else {
                        dvc.state = .Create
                    }
                }
            case "copySchedule":
                if let dvc = nvc.viewControllers.first as? CopyScheduleViewController {
                    dvc.dayProgram = dayProgram
                    dvc.dayOfTheWeek = dayOfTheWeek
                }
            default:
                break
            }
        }
    }

    //MARK: - NewSwitchTableViewControllerDelegate
    func newSwitch(contoller: NewSwitchTableViewController, didCreateNewSwitch newSwitch: Switch) {
        tableView.reloadData()
        let numberOfRows = tableView.numberOfRowsInSection(1)
        let indexPath = NSIndexPath(forRow: numberOfRows - 1, inSection: 1)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
}
