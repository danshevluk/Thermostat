//
//  CopyScheduleViewController.swift
//  Thermostat
//
//  Created by Dan K. on 2015-08-29.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

class CopyScheduleViewController: UITableViewController {
    
    var dayProgram: DayProgram!
    var dayOfTheWeek: Int!
    
    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var daysToCopy = [false, false, false, false, false, false, false]

    override func viewDidLoad() {
        super.viewDidLoad()

        dayOfTheWeek =  dayOfTheWeek == 0 ? 6 : dayOfTheWeek - 1
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdays.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DayCell", forIndexPath: indexPath) as! UITableViewCell
        
        if daysToCopy[indexPath.row] {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        cell.textLabel?.text = weekdays[indexPath.row]

        if indexPath.row == dayOfTheWeek {
            cell.backgroundColor = UIColor(white: 0.84, alpha: 1.0)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != dayOfTheWeek {
            daysToCopy[indexPath.row] = !daysToCopy[indexPath.row]
            tableView.reloadData()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    @IBAction func copySchedule(sender: UIBarButtonItem) {
        for (index, dayToCopy) in enumerate(daysToCopy) {
            if dayToCopy == true {
                let day = index == 6 ? 0 : index + 1
                Thermostat.sharedInstance.program.days[day] = dayProgram.copy() as! DayProgram
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
