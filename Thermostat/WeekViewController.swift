//
//  WeekViewController.swift
//  Thermostat
//
//  Created by Dan K. on 2015-08-14.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

class WeekViewController: UITableViewController {
    
    // TODO: Use enum values (maybe)
    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdays.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WeekdayCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = weekdays[indexPath.row]
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dayViewController = segue.destinationViewController as? DayViewController,
            cell = sender as? UITableViewCell,
            rowIndexPath = tableView.indexPathForCell(cell) {
                if rowIndexPath.row == 6 {
                    dayViewController.dayOfTheWeek = 0
                } else {
                    dayViewController.dayOfTheWeek = rowIndexPath.row + 1
                }
                dayViewController.navigationItem.title = weekdays[rowIndexPath.row]
        }
    }
    
}
