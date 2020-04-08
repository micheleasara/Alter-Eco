import Foundation
import SwiftUI
import CoreData

//all the constants for carbon conversions come from:
//https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2019
//all units below have been converted to grams/kilometer

let CARBON_UNIT_CAR: Double = 175
let CARBON_UNIT_TRAIN: Double = 30
let CARBON_UNIT_PLANE: Double = 200
let CARBON_UNIT_WALKING: Double = 175
let KM_CONVERSION: Double = 0.001

let MAX_DAYS_IN_FEB: Int = 28

// Append new Event (tube, plane, walking, car) to Event database
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

// Query the Event database depending on predicate (date, motionType, distance, ...)
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

// Helper function to write formatted date based on date and specific hour
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

// Convert Event distance to carbon units
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

// Make use of general execute query function to query daily carbon for any motionType
func queryDailyCarbon(motionType: MeasuredActivity.MotionType, hourStart: String, hourEnd: String) -> Double {
    
    let dateNow = Date()
    
    let queryMeasuredActivities = executeQuery(query: NSPredicate(format: "motionType == %@ AND start <= %@ AND start >= %@", MeasuredActivity.motionTypeToString(type: motionType),combineTodayDateWithInterval(date: dateNow, hour: hourEnd) as NSDate, combineTodayDateWithInterval(date: dateNow, hour: hourStart) as NSDate))
    
    let carbonValue = computeCarbonUsage(measuredActivities: queryMeasuredActivities, type: motionType)

    
    return carbonValue
}

// Make use of general execute query function to query daily carbon for all motionType
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
