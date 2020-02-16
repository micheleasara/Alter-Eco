//
//  AppDelegate.swift
//  Alter Eco
//
//  Created by Satisfaction on 30/01/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import UIKit
import CoreMotion

import SQLite

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //create_database()
        //readActivityData()
        //print_database()
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
            var database : [String:Dictionary<CMMotionActivity.ActivityType, Double>] = [:]
            
            activities = activities.filter{($0.confidence == .high || $0.confidence == .medium) &&
                $0.getActivityType != CMMotionActivity.ActivityType.unknown}
            activities.sort{$1.startDate > $0.startDate}
            
            let groupedByDay = Dictionary(grouping: activities) { Calendar(identifier: .gregorian).dateComponents([.day, .month, .year], from: $0.startDate)}
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .short
        
            for (dateComponents, activitiesDay) in groupedByDay{
                var previousActivity : CMMotionActivity? = nil
                var totalTimeByActivity : [CMMotionActivity.ActivityType:Double] =
                    [CMMotionActivity.ActivityType.automotive:0,
                     CMMotionActivity.ActivityType.walking:0,
                     CMMotionActivity.ActivityType.pureStationary:0]
                
                for activity in activitiesDay{
                    if let previous = previousActivity {
                        var totalTime = totalTimeByActivity[previous.getActivityType]!
                        totalTime += activity.startDate.timeIntervalSince(previous.startDate)
                        totalTimeByActivity.updateValue(totalTime, forKey: previous.getActivityType)
                    }
                    previousActivity = activity
                }
                
                let date = Calendar(identifier: .gregorian).date(from: dateComponents)!
                database.updateValue(totalTimeByActivity, forKey: dateFormatter.string(from: date))
                previousActivity = nil
            }
            for (date, timeDict) in database{
                print("On \(date) we have:\n")
                for (activityType, total) in timeDict{
                    //print("\(CMMotionActivity.activityTypeToString(activity: activityType)):\(total.rounded())s")
                    append_database(append_motion: CMMotionActivity.activityTypeToString(activity: activityType), append_time: total.rounded(), append_date: date)
                }
            }
        }
        
        print_database()
    }

    func create_database() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!

            let db = try Connection("\(path)/motion_db.sqlite3")
        
            let motions = Table("motions")
            let motion_type = Expression<String>("MotionType")
            let time = Expression<Double>("Time")
            let date = Expression<String>("Date")

            print("Creates connection")
            
            try db.run(motions.create(ifNotExists: true) {
                t in
                
                t.column(motion_type)
                t.column(time)
                t.column(date)
                t.primaryKey(motion_type, date)
                //t.column(id, primaryKey: true) //, unique: true)
                })

        } catch {
                print("Cannot connect to the database")
        }
    }
    
    func append_database(append_motion: String, append_time: Double, append_date: String) {
        
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!

        do {
            let db = try Connection("\(path)/motion_db.sqlite3")
        
            let motions = Table("motions")
            let motion_type = Expression<String>("MotionType")
            let time = Expression<Double>("Time")
            let date = Expression<String>("Date")
            
            print("Opens existing database")
            
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
            let insert = motions.insert(motion_type <- append_motion, time <- append_time, date <- append_date)
            
            do {
                try db.run(insert)
            } catch {
                print("Cannot insert a row to existing table")
            }
        } catch {
            print("Cannot open existing database")
        }
    }
    
    func print_database() {
        
        let path = NSSearchPathForDirectoriesInDomains(
                    .documentDirectory, .userDomainMask, true
                ).first!
        do {
            let db = try Connection("\(path)/motion_db.sqlite3")
            do {
                let motions = Table("motions")
                let motion_type = Expression<String>("MotionType")
                let time = Expression<Double>("Time")
                let date = Expression<String>("Date")
            
                for motion in try db.prepare(motions) {
                    print("motion_type: \(String(describing: motion[motion_type])), time: \(motion[time]), date: \(motion[date])")
                }
            } catch {
                print("Cannot print")
            }
        } catch {
            print("Cannot connect to database to print")
        }
    }

    // MARK: UISceneSession Lifecycle
    func retrieve_database(query_motion_type: String, query_date: String) -> Double {
            
            let path = NSSearchPathForDirectoriesInDomains(
                        .documentDirectory, .userDomainMask, true
                    ).first!
            do {
                let db = try Connection("\(path)/motion_db.sqlite3")
                
                do {
                    let motions = Table("motions")
                    let motion_type = Expression<String>("MotionType")
                    let time = Expression<Double>("Time")
                    let date = Expression<String>("Date")
                    
    //                for motion in try db.prepare(motions.filter(motion_type == query_motion_type && date == query_date)) {
    //                    return motion[time]
    //                }
                    for motion in try db.prepare(motions.where(motion_type == query_motion_type && date == query_date)) {
                        print("motion time: \(motion[time])")
                        return motion[time]
                    }
                } catch {
                    print("Cannot print")
                }
            } catch {
                print("Cannot connect to database to print")
            }
            
            print("Got to 0.5")
            return 0.5
        }

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

extension CMMotionActivity{
    enum ActivityType {
        case pureStationary
        case walking
        case automotive
        case unknown
    }
    var getActivityType:ActivityType{
        if automotive  || cycling { return ActivityType.automotive }
        if walking || running { return ActivityType.walking }
        if stationary { return ActivityType.pureStationary }
        return ActivityType.unknown
    }
    static func activityTypeToString(activity:ActivityType) -> String{
        switch activity {
        case .automotive:
            return "automotive"
        case .pureStationary:
            return "pureStationary"
        case .walking:
            return "walking"
        default:
            return "unknown"
        }
    }
}
