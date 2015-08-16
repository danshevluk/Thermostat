//
//  SettingsViewController.swift
//  Thermostat
//
//  Created by Dan K. on 2015-08-11.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit
//import DatePickerCell
import ActionSheetPicker_3_0

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath),
            reuseIdentifier = cell.reuseIdentifier {
                switch reuseIdentifier {
                case "DayTempPicker", "NightTempPicker":
                    showDatePicker()
                case "DatePicker":
                    showDatePicker()
                default:
                    break
                }
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

//    private func showTempPicker() {
//        ActionSheetMultipleStringPicker.showPickerWithTitle("Multiple String Picker", rows: [
//            ["One", "Two", "A lot"],
//            ["Many", "Many more", "Infinite"]
//            ], initialSelection: [2, 2], doneBlock: {
//                picker, values, indexes in
//                
//                println("values = \(values)")
//                println("indexes = \(indexes)")
//                println("picker = \(picker)")
//                return
//            }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: view.superview)
//    }
    
    private func showDatePicker() {
        var datePicker = ActionSheetDatePicker(title: "Date And Time",
            datePickerMode: .DateAndTime,
            selectedDate: NSDate(),
            doneBlock: {
                picker, value, index in

                println("value = \(value)")
                println("index = \(index)")
                println("picker = \(picker)")
                return
            }, cancelBlock: { ActionStringCancelBlock in return },
            origin: view.superview)

        let secondsInWeek: NSTimeInterval = 7 * 24 * 60 * 60;
        datePicker.minimumDate = NSDate(timeInterval: -secondsInWeek, sinceDate: NSDate())
        datePicker.maximumDate = NSDate(timeInterval: secondsInWeek, sinceDate: NSDate())
        datePicker.minuteInterval = 20
        
        datePicker.showActionSheetPicker()
    }

}
