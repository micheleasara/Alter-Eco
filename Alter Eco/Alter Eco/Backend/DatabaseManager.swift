import Foundation
import SwiftUI
import CoreData

//all the constants for carbon conversions come from:
//https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2019
//all units below have been converted to kgrams/kilometer

public let CARBON_UNIT_CAR: Double = 0.175
public let CARBON_UNIT_TRAIN: Double = 0.030
public let CARBON_UNIT_PLANE: Double = 0.200
public let CARBON_UNIT_WALKING: Double = 0.175 // carbon saved with respect to a car
public let KM_CONVERSION: Double = 0.001

public protocol DBReader {
    // Queries the Event entity depending on predicate (date, motionType, distance, ...)
    func queryActivities(predicate: String?, args: [Any]?) throws -> [MeasuredActivity]
    // Executes a generic query with the given predicate
    func executeQuery(entity: String, predicate: String?, args:[Any]?) throws -> [Any]
}

public protocol DBWriter {
    // Appends new activity (tube, plane, walking, car) to Event table
    func append(activity: MeasuredActivity) throws
}

public protocol DBManager : AnyObject, DBReader, DBWriter {
    func distanceWithinInterval(motionType: MeasuredActivity.MotionType, from: Date, interval: TimeInterval) throws -> Double
    func distanceWithinIntervalAll(from: Date, interval: TimeInterval) throws -> Double

    // Make use of general execute query function to query daily carbon for any motionType
    func carbonWithinInterval(motionType: MeasuredActivity.MotionType, from:Date, interval:TimeInterval) throws -> Double
    // Make use of general execute query function to query daily carbon for all motionType
    func carbonWithinIntervalAll(from:Date, interval:TimeInterval) throws -> Double
    
    func updateScore(activity: MeasuredActivity) throws
    func updateLeague(newLeague: String) throws
    func retrieveLatestScore() throws -> UserScore
    func getFirstDate() throws -> Date
    
    func queryHourlyCarbon(motionType: MeasuredActivity.MotionType, hourStart: String, hourEnd: String) throws -> Double
    func queryHourlyCarbonAll(hourStart: String, hourEnd: String) throws -> Double
    func queryDailyCarbon(motionType: MeasuredActivity.MotionType, weekDayToDisplay: String) throws -> Double
    func queryDailyCarbonAll(weekDayToDisplay: String) throws -> Double
    func queryMonthlyCarbon(motionType:MeasuredActivity.MotionType, month: String) throws -> Double
    func queryMonthlyCarbonAll(month: String) throws -> Double
    func queryYearlyCarbon(motionType: MeasuredActivity.MotionType, year: String) throws -> Double
    func queryYearlyCarbonAll(year: String) throws -> Double
}

public protocol CarbonCalculator {
     func computeCarbonUsage(distance:Double, type: MeasuredActivity.MotionType) -> Double
}

public class CoreDataManager : DBManager, CarbonCalculator {
    
    private let persistentContainer : NSPersistentContainer
    
    // Returns CoreData's managed context
    private func getManagedContext() throws -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public init(persistentContainer : NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    public func executeQuery(entity: String, predicate: String?, args:[Any]?) throws -> [Any]{
        let managedContext = try getManagedContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        if predicate != nil && args != nil {
            fetchRequest.predicate = NSPredicate(format: predicate!, argumentArray: args!)
        }
        let queryResult = try managedContext.fetch(fetchRequest)
        
        return queryResult
    }
    
    public func queryActivities(predicate: String?, args:[Any]?) throws -> [MeasuredActivity] {
        var measuredActivities = [MeasuredActivity]()
        let queryResult = (try executeQuery(entity: "Event", predicate: predicate, args: args!)) as! [NSManagedObject]

        for result in queryResult {
            let motionType = MeasuredActivity.stringToMotionType(type: result.value(forKey: "motionType") as! String)
            let distance = result.value(forKey: "distance") as! Double
            let start = result.value(forKey: "start") as! Date
            let end = result.value(forKey: "end") as! Date
            measuredActivities.append(MeasuredActivity(motionType: motionType, distance: distance, start: start, end: end))
        }
        
        return measuredActivities
    }
    
    public func append(activity: MeasuredActivity) throws {
        let managedContext = try getManagedContext()
        let entity = NSEntityDescription.entity(forEntityName: "Event", in: managedContext)!
        let eventDB = NSManagedObject(entity: entity, insertInto: managedContext)

        eventDB.setValuesForKeys(["motionType" : MeasuredActivity.motionTypeToString(type: activity.motionType),
                                  "distance":activity.distance, "start":activity.start, "end":activity.end])

        try managedContext.save()
    }
    
    public func distanceWithinInterval(motionType: MeasuredActivity.MotionType, from: Date, interval: TimeInterval) throws -> Double {
        let motionString = MeasuredActivity.motionTypeToString(type: motionType)
        let endDate = Date(timeInterval: interval, since: from)
        // total distance among all activities occurred in the specified interval
        var distance = 0.0
        
        // get activities which share a portion of execution in time with the interval requested
        // e.g. for today's 2-3pm, the following should match: 2-3pm, 1-4pm, 1-2:30pm and 2:01-4pm (all relative to today)
        let queryMeasuredActivities = try queryActivities(predicate: "motionType == %@ AND ((start <= %@ AND end > %@) OR (start >= %@ AND start < %@))", args: [motionString, from as NSDate, from as NSDate, from as NSDate, endDate as NSDate])
        for measurement in queryMeasuredActivities {
            // get portion of time shared among this activity and the interval requested
            let sharedTime = min(measurement.end, endDate).timeIntervalSince(max(measurement.start, from))
            let activityDuration = measurement.end.timeIntervalSince(measurement.start)
            // get what proportion of this activity overlaps with the requested interval
            // then add its contribution to the total distance
            distance += (sharedTime/activityDuration) * measurement.distance
        }

        return distance
    }
    
    public func distanceWithinIntervalAll(from: Date, interval: TimeInterval) throws -> Double {
        var total = 0.0
        for motion in MeasuredActivity.MotionType.allCases {
            total += try distanceWithinInterval(motionType: motion, from: from, interval: interval)
        }
        return total
    }
    
    public func carbonWithinInterval(motionType: MeasuredActivity.MotionType, from: Date, interval: TimeInterval) throws -> Double {
        let distance = try distanceWithinInterval(motionType: motionType, from: from, interval: interval)
        let carbonValue = computeCarbonUsage(distance: distance, type: motionType)

        return carbonValue
    }
    
    public func carbonWithinIntervalAll(from: Date, interval: TimeInterval) throws -> Double {
        var carbonTotal : Double = 0
        for motion in MeasuredActivity.MotionType.allCases {
            carbonTotal += try carbonWithinInterval(motionType: motion, from: from, interval: interval)
        }
        
        return carbonTotal
    }
    
    public func updateScore(activity: MeasuredActivity) throws {
        let managedContext = try getManagedContext()

        // retrieve current score
        let queryResult = try executeQuery(entity: "Score", predicate:nil, args: nil) as! [NSManagedObject]
        if queryResult.count != 0 {
            let activityScore = UserScore(activity: activity, league: "", date: stringFromDate(Date()))
            let oldTotalPoints = queryResult[0].value(forKey: "score") as! Double
            queryResult[0].setValue(oldTotalPoints + activityScore.totalPoints!, forKey: "score")
            queryResult[0].setValue(activityScore.date!, forKey: "dateStr")
        }

        try managedContext.save()
    }
    
    public func updateLeague(newLeague: String) throws {
       let managedContext = try getManagedContext()
       let dateToday = Date()
       let dateTodayStr = stringFromDate(dateToday)
    
       // retrieve current userscore
        let queryResult = try executeQuery(entity: "Score", predicate: nil, args: nil) as! [NSManagedObject]
        if queryResult.count != 0 {
           queryResult[0].setValue(newLeague, forKey: "league")
           queryResult[0].setValue(dateTodayStr, forKey: "dateStr")
        }
    
        try managedContext.save()
    }
    
    public func retrieveLatestScore() throws -> UserScore {
        let userScore = UserScore.getInitialScore()

        let queryResult = try executeQuery(entity: "Score", predicate: nil, args: nil) as! [NSManagedObject]
        if queryResult.count != 0 {
            userScore.totalPoints = queryResult[0].value(forKey: "score") as? Double
            userScore.date = queryResult[0].value(forKey: "dateStr") as? String
            userScore.league = queryResult[0].value(forKey: "league") as? String
        } else {
            let managedContext = try getManagedContext()
            let entity = NSEntityDescription.entity(forEntityName: "Score", in: managedContext)!
            let eventDB = NSManagedObject(entity: entity, insertInto: managedContext)
            eventDB.setValuesForKeys(["dateStr": userScore.date!, "score": userScore.totalPoints!, "league": userScore.league!])
        }
        
        return userScore
    }
    
    public func getFirstDate() throws -> Date {
        var oldDate = Date()
        let managedContext = try getManagedContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        let queryResult = try managedContext.fetch(fetchRequest)
        if queryResult.count != 0 {
            oldDate = queryResult[0].value(forKey: "start") as! Date
        }
        return oldDate
    }
    
    public func queryHourlyCarbon(motionType: MeasuredActivity.MotionType, hourStart: String, hourEnd: String) throws -> Double {
        let startDate = setDateToSpecificHour(date: Date(), hour: hourStart)!
        let endDate = setDateToSpecificHour(date: Date(), hour: hourEnd)!
        let timeInterval = endDate.timeIntervalSince(startDate)
        return try carbonWithinInterval(motionType: motionType, from: startDate, interval: timeInterval)
    }

    public func queryHourlyCarbonAll(hourStart: String, hourEnd: String) throws -> Double {
        let startDate = setDateToSpecificHour(date: Date(), hour: hourStart)!
        let endDate = setDateToSpecificHour(date: Date(), hour: hourEnd)!
        let timeInterval = endDate.timeIntervalSince(startDate)
        return try carbonWithinIntervalAll(from: startDate, interval: timeInterval)
    }

    public func queryDailyCarbon(motionType: MeasuredActivity.MotionType, weekDayToDisplay: String) throws -> Double {
        let date = getDateFromWeekdayName(weekDayToDisplay: weekDayToDisplay)!
        return try carbonWithinInterval(motionType: motionType, from: date, interval: 24*60*60)
    }

    public func queryDailyCarbonAll(weekDayToDisplay: String) throws -> Double {
        let date = getDateFromWeekdayName(weekDayToDisplay: weekDayToDisplay)!
        return try carbonWithinIntervalAll(from: date, interval: 24*60*60)
    }

    public func queryMonthlyCarbon(motionType:MeasuredActivity.MotionType, month: String) throws -> Double {
        let currentYear = Calendar(identifier: .gregorian).component(.year, from: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        dateFormatter.locale = Locale(identifier: "en-UK")
        
        let monthToDisplay = monthNameToMonthNumber(month: month)
        let firstOfMonth = dateFormatter.date(from: String(currentYear) + "-" + monthToDisplay + "-01 00:00:00 +0000")!
        let lastOfMonth = setDateToSpecificHour(date: getEndDayOfMonth(date: firstOfMonth), hour: "23:59:59")!
        
        let interval = lastOfMonth.timeIntervalSince(firstOfMonth)
        return try carbonWithinInterval(motionType: motionType, from: firstOfMonth, interval: interval)
    }

    public func queryMonthlyCarbonAll(month: String) throws -> Double {
        var carbonTotal : Double = 0
        for motion in MeasuredActivity.MotionType.allCases {
            if motion != .unknown {
                carbonTotal += try queryMonthlyCarbon(motionType: motion, month: month)
            }
        }
        return carbonTotal
    }
    
    public func queryYearlyCarbon(motionType: MeasuredActivity.MotionType, year: String) throws -> Double {
        let yearStart = year + "-01-01 00:00:00 +0000"
        let yearEnd = year + "-12-31 23:59:59 +0000"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        dateFormatter.locale = Locale(identifier: "en-UK")
        
        let startDate = dateFormatter.date(from: yearStart)!
        let endDate = dateFormatter.date(from: yearEnd)!
        
        let interval = endDate.timeIntervalSince(startDate)
        return try carbonWithinInterval(motionType: motionType, from: startDate, interval: interval)
    }
    
    public func queryYearlyCarbonAll(year: String) throws -> Double {
        var carbonTotal : Double = 0
        for motion in MeasuredActivity.MotionType.allCases {
            if motion != .unknown {
                carbonTotal += try queryYearlyCarbon(motionType: motion, year: year)
            }
        }
        return carbonTotal
    }
    
    // Converts activity distance to carbon units
    public func computeCarbonUsage(distance:Double, type: MeasuredActivity.MotionType) -> Double {
        var carbonUnit = 0.0
        switch (type) {
        case .car:
            carbonUnit = CARBON_UNIT_CAR
        case .walking:
            carbonUnit = CARBON_UNIT_WALKING
        case .train:
            carbonUnit = CARBON_UNIT_TRAIN
        case .plane:
            carbonUnit = CARBON_UNIT_PLANE
        default:
            return 0.0
        }
        
        return distance * carbonUnit * KM_CONVERSION
    }
    
    private func getCumulativeDistance(measurements:[MeasuredActivity]) -> Double {
        var distance = 0.0
        for measurement in measurements {
            distance += measurement.distance
        }

        return distance
    }
    
    private func getEndDayOfMonth(date: Date) -> Date {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        let components = calendar.components([.year, .month], from: date)
        let startOfMonth = calendar.date(from: components)!
        var addendum = DateComponents()
        addendum.month = 1
        addendum.day = -1
        return calendar.date(byAdding: addendum, to: startOfMonth)!
    }

    private func stringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //yyyy
        dateFormatter.locale = Locale(identifier: "en-UK")
        return dateFormatter.string(from: date)
    }
    
    private func monthNameToMonthNumber(month: String) -> String {
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
    
    private func dayNameToDayNumber(_ day: String) -> Int {
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

    private func getDateFromWeekdayName(weekDayToDisplay: String) -> Date? {
        var dateToView = Date()
        let dayToday = Calendar(identifier: .gregorian).component(.weekday, from: Date())
        let dayDifference = dayToday - dayNameToDayNumber(weekDayToDisplay)
        dateToView = Calendar(identifier: .gregorian).date(byAdding: .day, value: dayDifference, to: dateToView)!
        return setDateToSpecificHour(date: dateToView, hour: "00:00:00")
    }
    
    private func setDateToSpecificHour(date: Date, hour: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en-UK")
        var todayDate = dateFormatter.string(from: date)
        todayDate = todayDate + " " + hour + " +0000"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        if let today = dateFormatter.date(from: todayDate) {
            return today
        }
        return nil
    }
}
