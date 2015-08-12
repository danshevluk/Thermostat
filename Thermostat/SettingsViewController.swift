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
    
    @IBOutlet weak var datePickerCell: DatePickerCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePickerCell.datePicker.addTarget(self, action: "datePicked:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect automatically if the cell is a DatePickerCell
        if let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as? DatePickerCell {
            cell.selectedInTableView(tableView)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Get the correct height if the cell is a DatePickerCell
        if let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as? DatePickerCell {
            return cell.datePickerHeight()
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    // MARK: - Observers
    func datePicked(datePicker: UIDatePicker) {
        let date = datePicker.date
        println(date)
        // Use it later, Luke
    }
    
}
