//
//  UserScoreCalculations.swift
//  Alter Eco
//
//  Created by Virtual Machine on 04/04/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

func updateUserScore(activity: MeasuredActivity) {
    
    // open database
    guard let appDelegate =
       UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    let managedContext =
      appDelegate.persistentContainer.viewContext
 
    // Fetch the userStatistiques (score, date, league)
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Score")

    let dateToday = Date()
    let dateTodayStr = stringFromDate(dateToday)
    
//    var currentUserScore = UserScore(totalPoints: 4, date: dateTodayStr, league: "sun.max")
    
    // retrieve current userscore
    do {
        let queryResult = try managedContext.fetch(fetchRequest)
        if queryResult.count != 0 {
            let oldTotalPoints = queryResult[0].value(forKey: "score") as! Double
            queryResult[0].setValue(oldTotalPoints + addScoreNewActivity(activity: activity), forKey: "score")
            queryResult[0].setValue(dateTodayStr, forKey: "dateStr")
        }
    } catch let error as NSError {
        print("Fetch failed: \(error), \(error.userInfo)")
    }
    
    do {
        try managedContext.save()
    } catch let error as NSError {
        print("Saving updated score failed: \(error), \(error.userInfo)")
    }
}

func updateUserScore(newLeague: String) {
    
    // open database
    guard let appDelegate =
       UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    let managedContext =
      appDelegate.persistentContainer.viewContext
 
    // Fetch the userStatistiques (score, date, league)
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Score")

    let dateToday = Date()
    let dateTodayStr = stringFromDate(dateToday)
 
    // retrieve current userscore
    do {
        let queryResult = try managedContext.fetch(fetchRequest)
        if queryResult.count != 0 {
            queryResult[0].setValue(getNewLeague(userLeague: queryResult[0].value(forKey: "league") as! String), forKey: "league")
            queryResult[0].setValue(dateTodayStr, forKey: "dateStr")
        }
    } catch let error as NSError {
        print("Fetch failed: \(error), \(error.userInfo)")
    }
    
    do {
        try managedContext.save()
    } catch let error as NSError {
        print("Saving updated score failed: \(error), \(error.userInfo)")
    }
}

func addScoreNewActivity(activity: MeasuredActivity) -> Double {
    
    let measuredActivityKms = activity.distance * KM_CONVERSION
    
    if measuredActivityKms != 0 {
        switch activity.motionType {
            case .car:
                return measuredActivityKms * CAR_PTS
            case .walking:
            return measuredActivityKms * WALKING_PTS
            case .plane:
            return measuredActivityKms * PLANE_PTS
            case .train:
            return measuredActivityKms * TUBE_PTS
            default:
                return 0
        }
    }
    
    return 0
}

func appendScoreToDatabase(score: UserScore) {
    
     guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
       return
     }
     
     let managedContext =
       appDelegate.persistentContainer.viewContext
     
     let entity =
       NSEntityDescription.entity(forEntityName: "Score",
                                  in: managedContext)!
     
     let eventDB = NSManagedObject(entity: entity,
                                  insertInto: managedContext)
     
    eventDB.setValuesForKeys(["dateStr": score.date, "score": score.totalPoints, "league": score.league])

    do {
       try managedContext.save()
     } catch let error as NSError {
       print("Could not save. \(error), \(error.userInfo)")
     }
}

func emptyDatabase() {
    
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
       return
     }
     
    //fetch old score currently in database
    let managedContext =
       appDelegate.persistentContainer.viewContext
    
   // delete all records from Person entity
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Score")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

    do {
      try managedContext.execute(deleteRequest)
    } catch let error as NSError {
      print("Could not delete all data. \(error), \(error.userInfo)")
    }
}

func stringFromDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd" //yyyy
    dateFormatter.locale = Locale(identifier: "en-UK")
    return dateFormatter.string(from: date)
}

func printUserScoreDatabase() {
    
    guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Score")
    
    do {
        let queryResult = try managedContext.fetch(fetchRequest)
        for result in queryResult {
            print("Result - score: ", result.value(forKey: "score") as! Double, " and date: ", result.value(forKey: "dateStr") as! String, " and league: ", result.value(forKey: "league")!)
        }
        
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
}

func retrieveLatestScore() -> UserScore {

    let dayToday = Date()
    let dayTodayStr = stringFromDate(dayToday)
    let userScore = UserScore(totalPoints: 10, date: dayTodayStr, league: "sun.max")
    var emptyDatabase = true
    
    guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
        return userScore
    }

    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Score")

    do {
        let queryResult = try managedContext.fetch(fetchRequest)
        print("There are: \(queryResult.count) records in the database SCORE!")
        if queryResult.count != 0 {
            print("There is more than 0 records")
            emptyDatabase = false
            userScore.totalPoints = queryResult[0].value(forKey: "score") as! Double
            userScore.date = queryResult[0].value(forKey: "dateStr") as! String
            userScore.league = queryResult[0].value(forKey: "league") as! String
            
            printUserScoreDatabase()
        }
        
//        for result in queryResult {
//            userScore.totalPoints = result.value(forKey: "score") as! Double
//            userScore.date = result.value(forKey: "dateStr") as! String
//            if result.value(forKey: "league") as? String != nil {qu
//                userScore.league = result.value(forKey: "league") as! String
//            }
//        }

    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    if emptyDatabase {
        appendScoreToDatabase(score: userScore)
    }
    
    return userScore
}

/* League Helper Functions */

func getNewLeague(userLeague: String) -> String {

    if userLeague == "sun.max" {
        return "flame.fill"
    }
    else if userLeague == "flame.fill" {
        return "tortoise.fill"
    }
    
    return "tortoise.fill"
}

func getNewLeagueName(leagueName: String) -> String {
    
    if leagueName == "flame.fill" {
        return "flame"
    }
    else if leagueName == "tortoise.fill" {
        return "tortoise"
    }
    
    return "sun"
    
}

func getLeagueProgress() -> Int {
    
    let userScore = retrieveLatestScore()
    
    if userScore.totalPoints >= 600 {
        updateUserScore(newLeague: getNewLeague(userLeague: userScore.league))
        return 0
    }
    
    print("Nb of icons colour should be less than: \(Int(((userScore.totalPoints / 600) * 6).rounded()))")
    
    return Int(((userScore.totalPoints / 600) * 6).rounded())
}

func getColor(iconNb: Int) -> Color {
    
    if iconNb <= getLeagueProgress() {
        return .blue
    }
    
    return .gray
}

/* For new stuff for profile page */

func getCurrentDay() -> Int {
    let date = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day], from: date)
    let dayOfMonth = components.day
    return dayOfMonth!
}

func getLastDayOfPreviousMonth(month: String) -> Int {

    switch month {
        case "01":
            return 31
        case "02":
            return 31
        case "03":
            return 28
        case "04":
            return 31
        case "05":
            return 30
        case "06":
            return 31
        case "07":
            return 30
        case "08":
            return 31
        case "09":
            return 31
        case "10":
            return 30
        case "11":
            return 31
        case "12":
            return 30
        default:
            return 0
    }
}

func getprevMonthDay(currentDay: Int, currentMonth: String) -> Int {
    
    var previousDay: Int = currentDay
    
    if currentDay == 31 || (currentDay == 30 && currentMonth == "03") {
        previousDay = getLastDayOfPreviousMonth(month: currentMonth)
    }
    
    return previousDay
}

func queryPastMonth(motionType: MeasuredActivity.MotionType, month: String, carbon: Bool = true) -> Double {

    let dateNow = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "LLLL"
    let myCalendar = Calendar(identifier: .gregorian)
    let monthToday = myCalendar.component(.month, from: dateNow)
    let monthToDisplay = getMonthToDisplay(month: month)
    
    let currentDay = getCurrentDay()
    let previousDay = getprevMonthDay(currentDay: currentDay, currentMonth: monthToDisplay)
    
    let previousMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
    let previousMonth = dateFormatter.string(from: previousMonthDate!)
    let prevMonthToDisplay = getMonthToDisplay(month: previousMonth)
    
    print("Month is: ", monthToday, " AND month we want is: ", monthToDisplay)

    let endDateTemp = "2020-" + monthToDisplay + "-"
    let endDate = endDateTemp + String(currentDay) + " 00:00:01 +0000"
    let startDateTemp = "2020-" + prevMonthToDisplay + "-"
    let startDate = startDateTemp + String(previousDay) + " 00:00:01 +0000"

    print("Start date is ", endDate)
    print("End date is ", startDate)

    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
    dateFormatter.locale = Locale(identifier: "en-UK")

    let queryDateStart = dateFormatter.date(from: startDate)
    let queryDateEnd = dateFormatter.date(from: endDate)

    let queryMeasuredActivities = executeQuery(query: NSPredicate(format: "motionType == %@ AND start >= %@ AND end <= %@", MeasuredActivity.motionTypeToString(type: motionType), queryDateStart! as NSDate, queryDateEnd! as NSDate))
    
    if(carbon == false){
        var measuredActivityDistance:Double = 0
        
        if (queryMeasuredActivities.count != 0) {
            for measuredActivity in queryMeasuredActivities {
                measuredActivityDistance = measuredActivityDistance + measuredActivity.distance
            }
        }
        return measuredActivityDistance
    }
    
    let carbonValue = computeCarbonUsage(measuredActivities: queryMeasuredActivities, type: motionType)
    return carbonValue

}

func queryTotalWeek() -> Double {
    let total = queryWeeklyCarbonAll(weekDayToDisplay: "Monday") +
                queryWeeklyCarbonAll(weekDayToDisplay: "Tuesday") +
                queryWeeklyCarbonAll(weekDayToDisplay: "Wednesday") +
                queryWeeklyCarbonAll(weekDayToDisplay: "Thursday") +
                queryWeeklyCarbonAll(weekDayToDisplay: "Friday") +
                queryWeeklyCarbonAll(weekDayToDisplay: "Saturday") +
                queryWeeklyCarbonAll(weekDayToDisplay: "Sunday")
    return total
}


//func updateScore(score: UserScore, queryDate: Date = Date()) -> UserScore {
//
//       //query walking
//    let walkingKm = queryDailyKm(motionType: MeasuredActivity.MotionType.walking,
//                                 hourStart: "00:00:00", hourEnd: "23:59:59", queryDate: queryDate)
//
//       //query car
//    let carKm = queryDailyKm(motionType: MeasuredActivity.MotionType.car,
//                             hourStart: "00:00:00", hourEnd: "23:59:59", queryDate: queryDate)
//
//    //query tube
//    let tubeKm = queryDailyKm(motionType: MeasuredActivity.MotionType.train,
//                              hourStart: "00:00:00", hourEnd: "23:59:59", queryDate: queryDate)
//
//    let planeKm = queryDailyKm(motionType: MeasuredActivity.MotionType.plane,
//                               hourStart: "00:00:00", hourEnd: "23:59:59", queryDate: queryDate)
//
//    //total kms
//    let totalKm = walkingKm + carKm + tubeKm + planeKm
//
//       //prevent division by 0
//       if totalKm == 0 {
//           score.totalPoints += 0
//           let dayTodayStr = stringFromDate(Date())
//           score.date = dayTodayStr
//           return score
//       }
//
//       else {
//           let walkingPoints = (walkingKm/totalKm) * WALKING_PTS
//           let carPoints = (walkingKm/totalKm) * CAR_PTS
//           let tubePoints = (walkingKm/totalKm) * TUBE_PTS
//           let planePoints = (planeKm/totalKm) * PLANE_PTS
//           score.totalPoints += (walkingPoints + carPoints + tubePoints + planePoints)
//           let dayTodayStr = stringFromDate(Date())
//           score.date = dayTodayStr
//           return score
//       }
//   }

//func replaceScore(queryDate: Date = Date()) {
//
//    let dateNow = queryDate
//    let dateTodayStr = stringFromDate(dateNow)
//    let dateYesterday = Calendar.current.date(byAdding: .day,value: -1, to: dateNow)
//    let dateYesterdayStr = stringFromDate(dateYesterday!)
//
//    let oldScore = UserScore(totalPoints: 0, date: dateYesterdayStr, league: "sun.max")
//
//    guard let appDelegate =
//        UIApplication.shared.delegate as? AppDelegate else {
//       return
//     }
//
//    //fetch old score currently in database
//    let managedContext =
//       appDelegate.persistentContainer.viewContext
//
//    //print("Day yesterday is: ", dateYesterdayStr)
//
//    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Score")
//    fetchRequest.predicate = NSPredicate(format: "dateStr == %@", dateYesterdayStr)
//
//    do {
//        let queryResult = try managedContext.fetch(fetchRequest)
////        let scoreDB : NSManagedObject
////            scoreDB = queryResult[0]
////
//        //find the attributes of old score
//        for result in queryResult {
//                oldScore.totalPoints = result.value(forKey: "score") as! Double
//                oldScore.league = result.value(forKey: "league") as! String
//        }
//
//        //print("The old Score totalPoints is: ", oldScore.totalPoints)
//    }
//
//    catch let error as NSError {
//      print("Could not fetch. \(error), \(error.userInfo)")
//    }
//
//    //update the score
////    let newScore = UserScore(totalPoints: 200, date: dateTodayStr) //updateScore(score: oldScore)
//    let newScore = updateScore(score: oldScore, queryDate: queryDate)
//
//    //replace old score with new score in database and update date
//    let entity = NSEntityDescription.entity(forEntityName: "Score",
//                                            in: managedContext)!
//
//    let scoreDB = NSManagedObject(entity: entity,
//    insertInto: managedContext)
//
//    //print("The new score is now updated: ", newScore.totalPoints)
//
//    emptyDatabase()
//    let newLeague = getLeagueProgress()
//
//    scoreDB.setValuesForKeys(["dateStr": dateTodayStr, "score": newScore.totalPoints])
//
//    do {
//       try managedContext.save()
//     } catch let error as NSError {
//       print("Could not save. \(error), \(error.userInfo)")
//     }
//}


//
//
//func retrieveScore(query: NSPredicate) -> UserScore {
//
//    let dayToday = Date()
//    let dayTodayStr = stringFromDate(dayToday)
//    let userScore = UserScore(totalPoints: 10, date: dayTodayStr, league: "flame.fill")
//
//    print(userScore.date)
//    print(userScore.totalPoints)
//
//    guard let appDelegate =
//      UIApplication.shared.delegate as? AppDelegate else {
//        return userScore
//    }
//
//    let managedContext = appDelegate.persistentContainer.viewContext
//    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Score")
//    fetchRequest.predicate = query
//
//    do {
//        let queryResult = try managedContext.fetch(fetchRequest)
//        for result in queryResult {
//            userScore.date = result.value(forKey: "dateStr") as! String
//            userScore.totalPoints = result.value(forKey: "score") as! Double
//        }
//
//    } catch let error as NSError {
//      print("Could not fetch. \(error), \(error.userInfo)")
//    }
//
//    return userScore
//}

////score calculation functions
//func queryDailyKm(motionType: MeasuredActivity.MotionType, hourStart: String, hourEnd: String, queryDate: Date = Date()) -> Double {
//
//    //let dateNow = Date()
//    var measuredActivityKms:Double = 0
//
//    let queryMeasuredActivities = executeQuery(query: NSPredicate(format: "motionType == %@ AND start <= %@ AND start >= %@", MeasuredActivity.motionTypeToString(type: motionType),combineTodayDateWithInterval(date: queryDate, hour: hourEnd) as NSDate, combineTodayDateWithInterval(date: queryDate, hour: hourStart) as NSDate))
//
//    if (queryMeasuredActivities.count != 0) {
//        for measuredActivity in queryMeasuredActivities {
//            measuredActivityKms += measuredActivity.distance
//        }
//    }
//
//    measuredActivityKms *= KM_CONVERSION
//
//    return measuredActivityKms
//}
