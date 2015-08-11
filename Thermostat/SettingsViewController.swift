//
//  SettingsViewController.swift
//  Thermostat
//
//  Created by Dan K. on 2015-08-11.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit
import DatePickerCell

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView,
            didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect automatically if the cell is a DatePickerCell.
        if let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
                as? DatePickerCell {
            cell.selectedInTableView(tableView)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Get the correct height if the cell is a DatePickerCell.
        if let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
                as? DatePickerCell {
            return cell.datePickerHeight()
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
}
