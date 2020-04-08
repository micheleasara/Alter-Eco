import Foundation
import SwiftUI
import CoreData

// Points awarded to userScore for each transport mode
let WALKING_PTS: Double = 10
let CAR_PTS: Double = 3
let TUBE_PTS: Double = 7
let PLANE_PTS: Double = 0

// ProgressBar Icons number
let POINTS_REQUIRED_FOR_NEXT_LEAGUE: Double = 3000
let ICON_ONE: Int = 1
let ICON_TWO: Int = 2
let ICON_THREE: Int = 3
let ICON_FOUR: Int = 4
let ICON_FIVE: Int = 5
let NUMBER_OF_ICONS: Double = 6

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

func updateUserLeague(newLeague: String) {
    
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
    
    if userScore.totalPoints >= POINTS_REQUIRED_FOR_NEXT_LEAGUE {
        updateUserLeague(newLeague: getNewLeague(userLeague: userScore.league))
        return 0
    }
    
    print("Nb of icons colour should be less than: \(Int(((userScore.totalPoints / POINTS_REQUIRED_FOR_NEXT_LEAGUE) * NUMBER_OF_ICONS).rounded()))")
    
    return Int(((userScore.totalPoints / POINTS_REQUIRED_FOR_NEXT_LEAGUE) * NUMBER_OF_ICONS).rounded())
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
