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
    var settings: Settings!

    override func viewDidLoad() {
        super.viewDidLoad()

        settings = (UIApplication.sharedApplication().delegate as! AppDelegate).settings
        copyButtonItem = UIBarButtonItem(title: "Copy",
            style: .Plain, target: self, action: "copySwitches:")
        addSwitchButtonItem = UIBarButtonItem(barButtonSystemItem: .Add,
            target: self, action: "addNewSwitch:")
        navigationItem.rightBarButtonItems = rightBarButtons()
        
        // Load the program of the selected weekday
        dayProgram = Thermostat.sharedInstance.program.days[dayOfTheWeek]
    }

    override func viewWillDisappear(animated: Bool) {
        saveSettingsAndWeekProgram()
    }

    func saveSettingsAndWeekProgram() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.saveSettings(settings)
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
            if let firstSwitchTypeControl = cell.viewWithTag(2) as? UISegmentedControl,
                    firstSwitch = dayProgram.switches.first {
                firstSwitchTypeControl.selectedSegmentIndex = firstSwitch.type.rawValue
            }
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

        let alert = UIAlertController(title: "Warning!", message: "Next switch will be joined with the previous one for schedule consistency.", preferredStyle: .Alert)

        let okActionHandler = { (_: UIAlertAction!) -> Void in
            let deletedIndexes = self.dayProgram.deleteSwitchAtIndex(indexPath.row)
            var indexPaths: [NSIndexPath] = []
            for row in deletedIndexes {
                let newIndexPath = NSIndexPath(forRow: row, inSection: indexPath.section)
                indexPaths.append(newIndexPath)
            }

            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Left)
        }

        if settings.showDeleteSwitchAlert {
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: okActionHandler))
            alert.addAction(UIAlertAction(title: "Don't show this again", style: .Default,
                handler: { (action) -> Void in
                    self.settings.showDeleteSwitchAlert = false
                    okActionHandler(action)
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
        else {
            okActionHandler(nil)
        }
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
           let alert = UIAlertController(title: "Warning", message: "Each day can start with day or night temperature. Use the switcher above.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
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
                if dayProgram.switches.count > 1 && settings.showEditFirstSwitchTypeAlert {
                    let alert = UIAlertController(title: "Warning!",
                        message: "Second switch will be joined with the first one for consistency.",
                        preferredStyle: .Alert)

                    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel,
                        handler: { (_) -> Void in
                            control.selectedSegmentIndex = type == .Day ? 1 : 0
                            self.tableView.reloadData()
                    }))

                    let okActionHandler = { (_: UIAlertAction!) -> Void in
                        self.dayProgram.changeFirstSwitchType(type)
                        self.tableView.reloadData()
                    }
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: okActionHandler))
                    alert.addAction(UIAlertAction(title: "Don't show this again", style: .Default, handler: { (action) -> Void in
                        self.settings.showEditFirstSwitchTypeAlert = false
                        okActionHandler(action)
                    }))
                    presentViewController(alert, animated: true, completion: nil)
                } else {
                    dayProgram.changeFirstSwitchType(type)
                    tableView.reloadData()
                }
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
