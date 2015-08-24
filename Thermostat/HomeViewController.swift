//
//  ViewController.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 15/07/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //Test test test
        let weekProgram = WeekProgram()
        println(weekProgram)
        let data = NSKeyedArchiver.archivedDataWithRootObject(weekProgram)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "weekProgram")
        let wpData = NSUserDefaults.standardUserDefaults().objectForKey("weekProgram") as! NSData
        let wp = NSKeyedUnarchiver.unarchiveObjectWithData(wpData) as! WeekProgram
        println(wp)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

