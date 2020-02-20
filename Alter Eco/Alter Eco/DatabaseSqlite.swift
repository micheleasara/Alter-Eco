//
//  DatabaseSqlite.swift
//  Alter Eco
//
//  Created by Maxime Redstone on 19/02/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import Foundation
import SQLite

func createDatabase() {
    do {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!

        let db = try Connection("\(path)/motion_db.sqlite3")
    
        let motions = Table("motions")
        let motionType = Expression<String>("motionType")
        let dateStart = Expression<Date>("dateStart")
        let dateEnd = Expression<Date>("dateEnd")
        let distance = Expression<Double>("distance")
        
        print("Creates connection")
        
        try db.run(motions.create(ifNotExists: true) {
            t in
            
            t.column(motionType)
            t.column(dateStart, primaryKey: true)
            t.column(dateEnd)
            t.column(distance)
            //t.primaryKey(dateStart) //t.column(id, primaryKey: true) //, unique: true)
        })

    } catch {
            print("Cannot connect to the database")
    }
}

func appendToDatabase(event: MeasuredActivity) {
    
    let path = NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true
    ).first!

    do {
        let db = try Connection("\(path)/motion_db.sqlite3")
    
        let motions = Table("motions")
        let motionType = Expression<String>("motionType")
        let dateStart = Expression<Date>("dateStart")
        let dateEnd = Expression<Date>("dateEnd")
        let distance = Expression<Double>("distance")
        
        print("Opens existing database")
        
        // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
        let insert = motions.insert(motionType <- motionTypeToString(type: event.motionType), dateStart <- event.start, dateEnd <- event.end, distance <- event.distance)
        do {
            try db.run(insert)
        } catch {
            print("Cannot insert a row to existing table")
        }
    } catch {
        print("Cannot open existing database")
    }
}

//func printDatabase() {
//    
//    let path = NSSearchPathForDirectoriesInDomains(
//                .documentDirectory, .userDomainMask, true
//            ).first!
//    do {
//        let db = try Connection("\(path)/motion_db.sqlite3")
//        do {
//            let motions = Table("motions")
//            let motionType = Expression<String>("motionType")
//            let dateStart = Expression<Date>("dateStart")
//            let dateEnd = Expression<Date>("dateEnd")
//            let distance = Expression<Double>("distance")
//        
//            for motion in try db.prepare(motions) {
//                print("motionType: \(String(describing: motion[motionType])), dateStart: \(motion[dateStart]), dateEnd: \(motion[dateEnd]), distance: \(motion[distance])")
//            }
//        } catch {
//            print("Cannot print")
//        }
//    } catch {
//        print("Cannot connect to database to print")
//    }
//}

// MARK: UISceneSession Lifecycle
func retrieveFromDatabase(queryDate: Date) -> MeasuredActivity? {
        
        let path = NSSearchPathForDirectoriesInDomains(
                    .documentDirectory, .userDomainMask, true
                ).first!
        do {
            let db = try Connection("\(path)/motion_db.sqlite3")
            
            do {
                let motions = Table("motions")
                let motionType = Expression<String>("motionType")
                let dateStart = Expression<Date>("dateStart")
                let dateEnd = Expression<Date>("dateEnd")
                let distance = Expression<Double>("distance")
                
                for motion in try db.prepare(motions.where(dateStart == queryDate)) {
                    let event = MeasuredActivity(motionType: stringToMotionType(type: motion[motionType]), distance: motion[distance], start: motion[dateStart], end: motion[dateEnd])
                    return event
                }
            } catch {
                print("Cannot print")
            }
        } catch {
            print("Cannot connect to database to print")
        }
    
        return nil
    }
