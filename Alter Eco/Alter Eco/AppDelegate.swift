//
//  AppDelegate.swift
//  Alter Eco
//
//  Created by Satisfaction on 30/01/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import UIKit
import CoreMotion

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        readActivityData()
        return true
    }
    
    func readActivityData(){
        let motionManager = CMMotionActivityManager()
        let now = Date()
        let start = Date(timeIntervalSinceNow: (-3600*24*10))
        
        motionManager.queryActivityStarting(from: start, to: now, to: OperationQueue.main, withHandler:getActivities)
    }
    
    func getActivities(motionActivities:[CMMotionActivity]?, error:Error?){
        if var activities = motionActivities {
            activities = activities.filter{$0.confidence == .high || $0.confidence == .medium}
            var database:[String:Dictionary<String, Any>?] = [:]
            
            print("\nPrinting pedestrian times (if any)...")
            let pedestrianActivities = activities.filter{$0.walking || $0.running}
            let pedestrianDB = computeDailyTimes(activities: pedestrianActivities)
            for (date, time) in pedestrianDB{
                print("On \(date) a total of \(time.rounded())s was spent as pedestrian (walking or running)")
            }
            database.updateValue(pedestrianDB, forKey: "pedestrian")
            
            print("\nPrinting automotive times (if any)...")
            let automotiveActivities = activities.filter{$0.automotive || $0.cycling}
            let automotiveDB = computeDailyTimes(activities: automotiveActivities)
            for (date, time) in automotiveDB{
                print("On \(date) a total of \(time.rounded())s was spent as automotive (including cycling)")
            }
            database.updateValue(automotiveDB, forKey: "automotive")
            
            print("\nPrinting stationary times (if any)...")
            let pureStationaryActivities = activities.filter{$0.stationary && !$0.automotive && !$0.cycling && !$0.running && !$0.walking}
            let stationaryDB = computeDailyTimes(activities: pureStationaryActivities)
            for (date, time) in stationaryDB{
                print("On \(date) a total of \(time.rounded())s was spent as purely stationary")
            }
            database.updateValue(stationaryDB, forKey: "stationary")
            
            print("\ndatabase has keys: \(database.keys)")
        }
    }
    
    func computeDailyTimes(activities:[CMMotionActivity]) -> Dictionary<String, TimeInterval>{
        
        let groupedByDay = Dictionary(grouping: activities) { Calendar(identifier: .gregorian).dateComponents([.day, .month, .year], from: $0.startDate)}
        
        var dailyTimes : [String:TimeInterval] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        for (dateComponents, activitiesDay) in groupedByDay{
            let dates = activitiesDay.map{$0.startDate}
            if (dates.count > 1){
                let date = Calendar(identifier: .gregorian).date(from: dateComponents)!
                dailyTimes.updateValue(dates.max()!.timeIntervalSince(dates.min()!),
                                         forKey: dateFormatter.string(from: date))
            }
        }
        
        return dailyTimes
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

