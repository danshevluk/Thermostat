//
//  SettingsViewController.swift
//  Thermostat
//
//  Created by Dan K. on 2015-08-11.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit
import CoreActionSheetPicker

class SettingsViewController: UITableViewController {

    var settings: Settings!

    override func viewDidLoad() {
        super.viewDidLoad()
        settings = (UIApplication.sharedApplication().delegate as! AppDelegate).settings
    }

    func createTemperaturePickerRows() -> [[String]] {
        var firstNumberStrings: [String] = []
        var secondNumberStrings: [String] = []
        for var i = 0; i < 25; i++ {
            firstNumberStrings.append("        \(i+5)")
        }

        for var i = 0; i < 10; i++ {
            secondNumberStrings.append(".\(i)               ")
        }

        return [firstNumberStrings, secondNumberStrings]
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if let content = cell.viewWithTag(2) as? UILabel {
            switch indexPath.row {
            case 0:
                content.text = "\(settings.dayTemperature)"
            case 1:
                content.text = "\(settings.nighTemperature)"
            case 2:
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd MMM h:mm a"
                content.text = dateFormatter.stringFromDate(settings.date)
            default:
                break
            }
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath),
            reuseIdentifier = cell.reuseIdentifier {
                switch reuseIdentifier {
                case "DayTempPicker":
                    showDayTempPicker()
                case "NightTempPicker":
                    showNightTempPicker()
                case "DatePicker":
                    showDatePicker()
                default:
                    break
                }
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    private func showDayTempPicker() {
        ActionSheetMultipleStringPicker.showPickerWithTitle("Day temperature",
            rows: createTemperaturePickerRows(),
            initialSelection: getPickerIndexFromTemperature(settings.dayTemperature), doneBlock: {
                (picker, values, indexes) in

                let newTemp = self.getTemperatureFromPickerIndexes(values)
                println("new temperature: \(newTemp)")
                self.settings.dayTemperature = newTemp
                self.tableView.reloadData()
            }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: view.superview)
    }

    private func showNightTempPicker() {
        ActionSheetMultipleStringPicker.showPickerWithTitle("Night temperature",
            rows: createTemperaturePickerRows(),
            initialSelection: getPickerIndexFromTemperature(settings.nighTemperature), doneBlock: {
                picker, values, indexes in

                let newTemp = self.getTemperatureFromPickerIndexes(values)
                println("new temperature: \(newTemp)")
                self.settings.nighTemperature = newTemp
                self.tableView.reloadData()
            }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: view.superview)
    }

    private func showDatePicker() {
        var datePicker = ActionSheetDatePicker(title: "Date And Time",
            datePickerMode: .DateAndTime,
            selectedDate: settings.date,
            doneBlock: {
                picker, value, index in
                if let newDate = value as? NSDate {
                    self.settings.date = newDate
                }
                self.tableView.reloadData()
            }, cancelBlock: { ActionStringCancelBlock in return },
            origin: view.superview)

//        let secondsInWeek: NSTimeInterval = 7 * 24 * 60 * 60;
//        datePicker.minimumDate = NSDate()
//        datePicker.maximumDate = NSDate(timeInterval: secondsInWeek, sinceDate: NSDate())
        datePicker.minuteInterval = 10
        
        datePicker.showActionSheetPicker()
    }


    private func getPickerIndexFromTemperature(temperature: Double) -> [Int] {
        let firstIndex = Int(temperature) - 5
        let secondIndex = Int((temperature * 10) % 10)

        return [firstIndex, secondIndex]
    }

    private func getTemperatureFromPickerIndexes(values: [AnyObject]) -> Double {
        let intPart = Double(values[0] as! Int + 5)
        let fraction = Double(values[1] as! Int)

        return intPart + 0.1 * fraction
    }

}
