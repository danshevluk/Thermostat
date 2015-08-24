//
//  AppDelegate.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 15/07/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var settings = Settings()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // to initialize timers and stuff
        let timeManager = TimeManager.sharedManager
        let thermostat = Thermostat.sharedInstance

        if let weekProgram = unarchiveWeekProgram() {
            Thermostat.sharedInstance.program = weekProgram
        }

        if let settings = unarchiveSettings() {
            self.settings = settings
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        saveWeekProgram(Thermostat.sharedInstance.program)
        saveSettings(settings)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        if let weekProgram = unarchiveWeekProgram() {
            Thermostat.sharedInstance.program = weekProgram
        }

        if let settings = unarchiveSettings() {
            self.settings = settings
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        saveWeekProgram(Thermostat.sharedInstance.program)
        saveSettings(settings)
    }

    func saveSettings(settings: Settings) {
        let settingsData = NSKeyedArchiver.archivedDataWithRootObject(self.settings)
        NSUserDefaults.standardUserDefaults().setObject(settingsData, forKey: "settings")
    }

    func unarchiveSettings() -> Settings? {
        if let settingsData = NSUserDefaults.standardUserDefaults().objectForKey("settings") as? NSData {
            let settings = NSKeyedUnarchiver.unarchiveObjectWithData(settingsData) as? Settings
            return settings
        }

        return nil
    }

    func saveWeekProgram(program: WeekProgram) {
        let weekProgramData = NSKeyedArchiver.archivedDataWithRootObject(Thermostat.sharedInstance.program)
        NSUserDefaults.standardUserDefaults().setObject(weekProgramData, forKey: "weekProgram")
    }

    func unarchiveWeekProgram() -> WeekProgram? {
        if let weekProgramData = NSUserDefaults.standardUserDefaults().objectForKey("weekProgram") as? NSData {
            let weekProgram = NSKeyedUnarchiver.unarchiveObjectWithData(weekProgramData) as? WeekProgram
            return weekProgram
        }

        return nil
    }
}

