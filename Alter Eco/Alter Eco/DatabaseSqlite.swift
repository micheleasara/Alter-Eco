import Foundation
import SwiftUI
import CoreData

//all the constants for carbon conversions come from:
//https://www.carbonindependent.org/21.html
//all units below have been converted to grams/kilometer

let CARBON_UNIT_CAR: Double = 499
let CARBON_UNIT_TRAIN: Double = 161
let CARBON_UNIT_PLANE: Double = 512
let CARBON_UNIT_WALKING: Double = 499
let KM_CONVERSION: Double = 0.001
let WALKING_PTS: Double = 10
let CAR_PTS: Double = 3
let TUBE_PTS: Double = 7
let PLANE_PTS: Double = 0
let MAX_DAYS_IN_FEB: Int = 28

func appendToDatabase(activity: MeasuredActivity) {
     guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
       return
     }
     
     let managedContext =
       appDelegate.persistentContainer.viewContext
     
     let entity =
       NSEntityDescription.entity(forEntityName: "Event",
                                  in: managedContext)!
     
     let eventDB = NSManagedObject(entity: entity,
                                  insertInto: managedContext)
     
    eventDB.setValuesForKeys(["motionType" : MeasuredActivity.motionTypeToString(type: activity.motionType), "distance":activity.distance, "start":activity.start, "end":activity.end ])

    do {
       try managedContext.save()
     } catch let error as NSError {
       print("Could not save. \(error), \(error.userInfo)")
     }
}

func executeQuery(query: NSPredicate) -> [MeasuredActivity] {
    var measuredActivities = [MeasuredActivity]()

    guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
        return measuredActivities
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
    fetchRequest.predicate = query
    
    do {
        let queryResult = try managedContext.fetch(fetchRequest)
        
        for result in queryResult {
            let motionType = MeasuredActivity.stringToMotionType(type: result.value(forKey: "motionType") as! String)
            let distance = result.value(forKey: "distance") as! Double
            let start = result.value(forKey: "start") as! Date
            let end = result.value(forKey: "end") as! Date
            measuredActivities.append(MeasuredActivity(motionType: motionType, distance: distance, start: start, end: end))
        }
        
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    return measuredActivities
}


func combineTodayDateWithInterval(date: Date, hour: String) -> Date {

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.locale = Locale(identifier: "en-UK")
    var todayDate = dateFormatter.string(from: date)
    todayDate = todayDate + " " + hour + " +0000"
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
    if let today = dateFormatter.date(from: todayDate) {
        return today
    }
    return date
}

func computeCarbonUsage(measuredActivities: [MeasuredActivity], type: MeasuredActivity.MotionType) -> Double {
    
    var measuredActivityDistance:Double = 0
    
    if (measuredActivities.count != 0) {
        for measuredActivity in measuredActivities {
            measuredActivityDistance = measuredActivityDistance + measuredActivity.distance
        }
    }
    var CARBON_UNIT=0.0
    switch (type) {
    case .car:
        CARBON_UNIT=CARBON_UNIT_CAR
    case .walking:
        CARBON_UNIT=CARBON_UNIT_WALKING
    case .train:
        CARBON_UNIT=CARBON_UNIT_TRAIN
    case .plane:
        CARBON_UNIT=CARBON_UNIT_PLANE
    default:
        return 0
    }
    
    return Double(measuredActivityDistance) * CARBON_UNIT * KM_CONVERSION
    
}

func queryDailyCarbon(motionType: MeasuredActivity.MotionType, hourStart: String, hourEnd: String) -> Double {
    
    let dateNow = Date()
    
    let queryMeasuredActivities = executeQuery(query: NSPredicate(format: "motionType == %@ AND start <= %@ AND start >= %@", MeasuredActivity.motionTypeToString(type: motionType),combineTodayDateWithInterval(date: dateNow, hour: hourEnd) as NSDate, combineTodayDateWithInterval(date: dateNow, hour: hourStart) as NSDate))
    
    let carbonValue = computeCarbonUsage(measuredActivities: queryMeasuredActivities, type: motionType)

    
    return carbonValue
}

func queryDailyCarbonAll(hourStart: String, hourEnd: String) -> Double {
    
    let carbonValue = queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: hourStart, hourEnd: hourEnd) + queryDailyCarbon(motionType: MeasuredActivity.MotionType.train,hourStart: hourStart, hourEnd: hourEnd) + queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane,hourStart: hourStart, hourEnd: hourEnd)
    
    return carbonValue
}

func getWeekDayToDisplay(day: String) -> Int {
    
    switch day {
        case "Sunday":
            return 1
        case "Monday":
            return 2
        case "Tuesday":
            return 3
        case "Wednesday":
            return 4
        case "Thursday":
            return 5
        case "Friday":
            return 6
        case "Saturday":
            return 7
        default:
            return 0
        }
}

func getWeekDayDate(weekDayToDisplay: Int, dayToday: Int) -> [Date] {
    
    var dateToView = Date()
    var dateToViewAM = Date()
    var dateToViewPM = Date()
    
    if dayToday > weekDayToDisplay {
        let dayDifference = dayToday - weekDayToDisplay
        dateToView = Calendar.current.date(byAdding: .day, value: -dayDifference, to: dateToView)!
        dateToViewAM = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: dateToView)!
        dateToViewPM = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: dateToView)! //SHOULD GO TO 24
        return [dateToViewAM, dateToViewPM]
    }
    else if dayToday < weekDayToDisplay {
        let dayDifference = weekDayToDisplay - dayToday
        dateToView = Calendar.current.date(byAdding: .day, value: dayDifference, to: dateToView)!
        dateToViewAM = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of:dateToView)!
        dateToViewPM = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: dateToView)!
        return [dateToViewAM, dateToViewPM]
    }
    
    dateToViewAM = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of:dateToView)!
    dateToViewPM = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of:dateToView)!
    
    return [dateToViewAM, dateToViewPM]
}

func queryWeeklyCarbon(motionType: MeasuredActivity.MotionType, weekDayToDisplay: String) -> Double {
    
    let dateNow = Date()
    
    let myCalendar = Calendar(identifier: .gregorian)
    let dayToday = myCalendar.component(.weekday, from: dateNow) // 1-7 beginning on Sunday
    let weekDayToDisplay = getWeekDayToDisplay(day: weekDayToDisplay)
    
    let queryDate = getWeekDayDate(weekDayToDisplay: weekDayToDisplay, dayToday: dayToday)
    
    let queryMeasuredActivities = executeQuery(query: NSPredicate(format: "motionType == %@ AND start >= %@ AND end <= %@", MeasuredActivity.motionTypeToString(type: motionType), queryDate[0] as NSDate, queryDate[1] as NSDate))
    
    let carbonValue = computeCarbonUsage(measuredActivities: queryMeasuredActivities, type: motionType)

    
    return carbonValue
}

func queryWeeklyCarbonAll(weekDayToDisplay: String) -> Double {
    
    let carbonValue = queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay:  weekDayToDisplay) + queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay:  weekDayToDisplay) + queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay:  weekDayToDisplay)
    
    return carbonValue
}

func getMonthToDisplay(month: String) -> String {
    
    switch month {
        case "January":
            return "01"
        case "February":
            return "02"
        case "March":
            return "03"
        case "April":
            return "04"
        case "May":
            return "05"
        case "June":
            return "06"
        case "July":
            return "07"
        case "August":
            return "08"
        case "September":
            return "09"
        case "October":
            return "10"
        case "November":
            return "11"
        case "December":
            return "12"
        default:
            return "00"
    }
}


func getEndDayOfMonth(month: String) -> String {
    switch month {
        case "January":
            return "31"
        case "February":
            return "28"
        case "March":
            return "31"
        case "April":
            return "30"
        case "May":
            return "31"
        case "June":
            return "30"
        case "July":
            return "31"
        case "August":
            return "31"
        case "September":
            return "30"
        case "October":
            return "31"
        case "November":
            return "30"
        case "December":
            return "31"
        default:
            return "00"
    }
}
func queryMonthlyCarbon(motionType: MeasuredActivity.MotionType, month: String) -> Double {
    
//    let dateNow = Date()
//    let myCalendar = Calendar(identifier: .gregorian)
//    let monthToday = myCalendar.component(.month, from: dateNow)
    let monthToDisplay = getMonthToDisplay(month: month)
    let monthStart = "2020-" + monthToDisplay + "-01 00:00:01 +0000"
    let endDayOfMonth = getEndDayOfMonth(month: month)
    let monthEnd = "2020-" + monthToDisplay + "-" + endDayOfMonth + " 23:59:59 +0000"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
    dateFormatter.locale = Locale(identifier: "en-UK")
    let queryDateStart = dateFormatter.date(from: monthStart)
    let queryDateEnd = dateFormatter.date(from: monthEnd)
    let queryMeasuredActivities = executeQuery(query: NSPredicate(format: "motionType == %@ AND start >= %@ AND end <= %@", MeasuredActivity.motionTypeToString(type: motionType), queryDateStart! as NSDate, queryDateEnd! as NSDate))
    let carbonValue = computeCarbonUsage(measuredActivities: queryMeasuredActivities, type: motionType)

    return carbonValue


}
func queryMonthlyCarbonAll(month: String) -> Double {
    
    let carbonValue = queryMonthlyCarbon(motionType: MeasuredActivity.MotionType.car, month: month) + queryMonthlyCarbon(motionType: MeasuredActivity.MotionType.train,month: month) +  queryMonthlyCarbon(motionType: MeasuredActivity.MotionType.plane,month: month)
   
    return carbonValue
}



func queryYearlyCarbon(motionType: MeasuredActivity.MotionType, year: String) -> Double {
    
    
    let yearToDisplay = year
    
    
    let yearStart = yearToDisplay + "-01-01 00:00:01 +0000"
    let yearEnd = yearToDisplay + "-12-31 23:59:00 +0000"

    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
    dateFormatter.locale = Locale(identifier: "en-UK")
    
    if let queryDateStart = dateFormatter.date(from: yearStart)
    {
       
        if let queryDateEnd = dateFormatter.date(from: yearEnd)
        {
            let queryMeasuredActivities = executeQuery(query: NSPredicate(format: "motionType == %@ AND start >= %@ AND end <= %@", MeasuredActivity.motionTypeToString(type: motionType), queryDateStart as NSDate, queryDateEnd as NSDate))
            let carbonValue = computeCarbonUsage(measuredActivities: queryMeasuredActivities, type: motionType)
            return carbonValue
        }
    }
    return 0
}

func queryYearlyCarbonAll(year: String) -> Double {

    
     let carbonValue = queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: year) +  queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train,year: year) + queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane,year: year)
    
    return carbonValue
}
//score calculation functions
func queryDailyKm(motionType: MeasuredActivity.MotionType, hourStart: String, hourEnd: String, queryDate: Date = Date()) -> Double {
    
    //let dateNow = Date()
    var measuredActivityKms:Double = 0
    
    let queryMeasuredActivities = executeQuery(query: NSPredicate(format: "motionType == %@ AND start <= %@ AND start >= %@", MeasuredActivity.motionTypeToString(type: motionType),combineTodayDateWithInterval(date: queryDate, hour: hourEnd) as NSDate, combineTodayDateWithInterval(date: queryDate, hour: hourStart) as NSDate))
    
    if (queryMeasuredActivities.count != 0) {
        for measuredActivity in queryMeasuredActivities {
            measuredActivityKms += measuredActivity.distance
        }
    }
    
    measuredActivityKms *= KM_CONVERSION
    
    return measuredActivityKms
}


func updateScore(score: UserScore, queryDate: Date = Date()) -> UserScore {
     
       //query walking
    let walkingKm = queryDailyKm(motionType: MeasuredActivity.MotionType.walking,
                                 hourStart: "00:00:00", hourEnd: "23:59:59", queryDate: queryDate)
       
       //query car
    let carKm = queryDailyKm(motionType: MeasuredActivity.MotionType.car,
                             hourStart: "00:00:00", hourEnd: "23:59:59", queryDate: queryDate)
       
    //query tube
    let tubeKm = queryDailyKm(motionType: MeasuredActivity.MotionType.train,
                              hourStart: "00:00:00", hourEnd: "23:59:59", queryDate: queryDate)
        
    let planeKm = queryDailyKm(motionType: MeasuredActivity.MotionType.plane,
                               hourStart: "00:00:00", hourEnd: "23:59:59", queryDate: queryDate)
        
    //total kms
    let totalKm = walkingKm + carKm + tubeKm + planeKm
        
       //prevent division by 0
       if totalKm == 0 {
           score.totalPoints += 0
           let dayTodayStr = stringFromDate(Date())
           score.date = dayTodayStr
           return score
       }
       
       else {
           let walkingPoints = (walkingKm/totalKm) * WALKING_PTS
           let carPoints = (walkingKm/totalKm) * CAR_PTS
           let tubePoints = (walkingKm/totalKm) * TUBE_PTS
           let planePoints = (planeKm/totalKm) * PLANE_PTS
           score.totalPoints += (walkingPoints + carPoints + tubePoints + planePoints)
           let dayTodayStr = stringFromDate(Date())
           score.date = dayTodayStr
           return score
       }
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
     
    eventDB.setValuesForKeys(["dateStr": score.date, "score": score.totalPoints])

    do {
       try managedContext.save()
     } catch let error as NSError {
       print("Could not save. \(error), \(error.userInfo)")
     }
}

func stringFromDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd" //yyyy
    dateFormatter.locale = Locale(identifier: "en-UK")
    return dateFormatter.string(from: date)
}

func replaceScore(queryDate: Date = Date()) {
    
    let dateNow = queryDate
    let dateTodayStr = stringFromDate(dateNow)
    let dateYesterday = Calendar.current.date(byAdding: .day,value: -1, to: dateNow)
    let dateYesterdayStr = stringFromDate(dateYesterday!)
    
    let oldScore = UserScore(totalPoints: 0, date: dateYesterdayStr)
    
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
       return
     }
     
    //fetch old score currently in database
    let managedContext =
       appDelegate.persistentContainer.viewContext
    
    //print("Day yesterday is: ", dateYesterdayStr)
    
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Score")
    fetchRequest.predicate = NSPredicate(format: "dateStr == %@", dateYesterdayStr)
    
    do {
        let queryResult = try managedContext.fetch(fetchRequest)
//        let scoreDB : NSManagedObject
//            scoreDB = queryResult[0]
//
        //find the attributes of old score
        for result in queryResult {
                oldScore.totalPoints = result.value(forKey: "score") as! Double
        }
        
        //print("The old Score totalPoints is: ", oldScore.totalPoints)
    }
    
    catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    //update the score
//    let newScore = UserScore(totalPoints: 200, date: dateTodayStr) //updateScore(score: oldScore)
    let newScore = updateScore(score: oldScore, queryDate: queryDate)
    
    //replace old score with new score in database and update date
    let entity = NSEntityDescription.entity(forEntityName: "Score",
                                            in: managedContext)!
    
    let scoreDB = NSManagedObject(entity: entity,
    insertInto: managedContext)
    
    //print("The new score is now updated: ", newScore.totalPoints)
    
    emptyDatabase()
    
    scoreDB.setValuesForKeys(["dateStr": dateTodayStr, "score": newScore.totalPoints])
    
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


func retrieveScore(query: NSPredicate) -> UserScore {
    
    let dayToday = Date()
    let dayTodayStr = stringFromDate(dayToday)
    let userScore = UserScore(totalPoints: 5, date: dayTodayStr)
    
    print(userScore.date)
    print(userScore.totalPoints)

    guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
        return userScore
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Score")
    fetchRequest.predicate = query
    
    do {
        let queryResult = try managedContext.fetch(fetchRequest)
        for result in queryResult {
            userScore.date = result.value(forKey: "dateStr") as! String
            userScore.totalPoints = result.value(forKey: "score") as! Double
        }
        
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    return userScore
}

func retrieveLatestScore() -> UserScore {
    
    let dayToday = Date()
    let dayTodayStr = stringFromDate(dayToday)
    let userScore = UserScore(totalPoints: -6, date: dayTodayStr)
    
    guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
        return userScore
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Score")
    
    do {
        let queryResult = try managedContext.fetch(fetchRequest)
        for result in queryResult {
            userScore.date = result.value(forKey: "dateStr") as! String
            userScore.totalPoints = result.value(forKey: "score") as! Double
        }
        
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    return userScore
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
            print("Result - score: ", result.value(forKey: "score") as! Double, " and date: ", result.value(forKey: "dateStr") as! String)
        }
        
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
}

///For new stuff for profile page

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
