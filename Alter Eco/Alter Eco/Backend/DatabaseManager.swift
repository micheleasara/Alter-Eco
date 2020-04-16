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

/// Represents an interface for a reader of AlterEco's databases.
public protocol DBReader {
    /**
    Queries the Event entity with a predicate.
    - Parameter predicate: Predicate used to select rows.
    - Parameter args: List of arguments to include in the predicate.
    - Returns: List of activities that satisfy the predicate.
    */
    func queryActivities(predicate: String?, args: [Any]?) throws -> [MeasuredActivity]
    /**
    Queries the given entity with a predicate.
    - Parameter entity: entity name as a string.
    - Parameter predicate: Predicate used to select rows.
    - Parameter args: List of arguments to include in the predicate.
    - Returns: List of objects that satisfy the predicate.
    */
    func executeQuery(entity: String, predicate: String?, args:[Any]?) throws -> [Any]
}

/// Represents an interface for a writer of AlterEco's databases.
public protocol DBWriter {
    /// Appends an activity to the Event entity.
    func append(activity: MeasuredActivity) throws
    /// Updates score by adding score computed from a given activity.
    func updateScore(activity: MeasuredActivity) throws
}

/// Represents an interface to an object able to read, write and perform sophisticated queries on AlterEco's databases.
public protocol DBManager : AnyObject, DBReader, DBWriter {
    /**
    Returns the cumulative distance for the given motion type and in the specified timeframe.
     - Parameter motionType: the only motion type to consider.
     - Parameter from: starting date.
     - Parameter interval: interval to be added to the starting date.
     */
    func distanceWithinInterval(motionType: MeasuredActivity.MotionType, from: Date, interval: TimeInterval) throws -> Double
    /**
    Returns the cumulative distance for all motion types in the specified timeframe.
     - Parameter from: starting date.
     - Parameter interval: interval to be added to the starting date.
     */
    func distanceWithinIntervalAll(from: Date, interval: TimeInterval) throws -> Double

    /**
    Returns the cumulative carbon output for the given motion type and in the specified timeframe.
     - Parameter motionType: the only motion type to consider.
     - Parameter from: starting date.
     - Parameter interval: interval to be added to the starting date.
     */
    func carbonWithinInterval(motionType: MeasuredActivity.MotionType, from:Date, interval:TimeInterval) throws -> Double
    /**
    Returns the cumulative carbon output for all motion types and in the specified timeframe.
     - Parameter from: starting date.
     - Parameter interval: interval to be added to the starting date.
     */
    func carbonWithinIntervalAll(from:Date, interval:TimeInterval) throws -> Double
    
    /// Updates the league attribute of the Score entity with the given string.
    func updateLeague(newLeague: String) throws
    /**
    Retrieves the latest UserScore in the Score entity. If no score if present, it is initialized with a default value.
    - Remark: Initial value is described in UserScore.getInitialScore()
    - Returns: A UserScore object having its properties set to the values in the database.
     */
    func retrieveLatestScore() throws -> UserScore
    /// Returns the earliest start date within the Event entity.
    func getFirstDate() throws -> Date
    
    
    /// Returns the carbon output produced in the given hours for the current day and for the given motion type.
    func queryHourlyCarbon(motionType: MeasuredActivity.MotionType, hourStart: String, hourEnd: String) throws -> Double
    /// Returns the carbon output produced in the given hours for the current day.
    func queryHourlyCarbonAll(hourStart: String, hourEnd: String) throws -> Double
    /// Returns the carbon output produced in the given day for the current week and for the given motion type.
    func queryDailyCarbon(motionType: MeasuredActivity.MotionType, weekDayToDisplay: String) throws -> Double
    /// Returns the carbon output produced in the given day for the current week.
    func queryDailyCarbonAll(weekDayToDisplay: String) throws -> Double
    /// Returns the carbon output produced in the given month for the current year and for the given motion type.
    func queryMonthlyCarbon(motionType:MeasuredActivity.MotionType, month: String) throws -> Double
    /// Returns the carbon output produced in the given month for the current year.
    func queryMonthlyCarbonAll(month: String) throws -> Double
    /// Returns the carbon output produced in the given year for the given motion type.
    func queryYearlyCarbon(motionType: MeasuredActivity.MotionType, year: String) throws -> Double
    /// Returns the carbon output produced in the given year.
    func queryYearlyCarbonAll(year: String) throws -> Double
}

public protocol CarbonCalculator {
    /// Returns the carbon output produced for the given distance and for the given motion type.
    func computeCarbonUsage(distance:Double, type: MeasuredActivity.MotionType) -> Double
}


/// Represents a database manager that provides an I/O interface with the CoreData framework. Also provides carbon conversion utilities.
public class CoreDataManager : DBManager, CarbonCalculator {
    
    private let persistentContainer : NSPersistentContainer
    
    private func getManagedContext() throws -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /**
    Initializes a new database manager that interacts with the Core Data framework.
    - Parameter persistentContainer: A container that encapsulates the Core Data stack.
    */
    public init(persistentContainer : NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    /**
    Queries the given entity with a predicate.
    - Parameter entity: entity name as string.
    - Parameter predicate: Predicate used to select rows.
    - Parameter args: List of arguments to include in the predicate.
    - Returns: List of objects that satisfy the predicate.
    - Remark: See .xcdatamodeld file for information about valid entities.
    */
    public func executeQuery(entity: String, predicate: String?, args:[Any]?) throws -> [Any]{
        let managedContext = try getManagedContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        if predicate != nil && args != nil {
            fetchRequest.predicate = NSPredicate(format: predicate!, argumentArray: args!)
        }
        let queryResult = try managedContext.fetch(fetchRequest)
        
        return queryResult
    }
    
    /**
    Queries the Event entity with a predicate.
    - Parameter predicate: Predicate used to select rows.
    - Parameter args: List of arguments to include in the predicate.
    - Returns: List of activities that satisfy the predicate.
    */
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
    
    /// Appends an activity to the Event entity.
    public func append(activity: MeasuredActivity) throws {
        let managedContext = try getManagedContext()
        let entity = NSEntityDescription.entity(forEntityName: "Event", in: managedContext)!
        let eventDB = NSManagedObject(entity: entity, insertInto: managedContext)

        eventDB.setValuesForKeys(["motionType" : MeasuredActivity.motionTypeToString(type: activity.motionType),
                                  "distance":activity.distance, "start":activity.start, "end":activity.end])

        try managedContext.save()
    }
    
    /**
    Returns the cumulative distance in meters for the given motion type and in the specified timeframe.
     - Parameter motionType: the only motion type to consider.
     - Parameter from: starting date.
     - Parameter interval: interval to be added to the starting date.
     */
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
    
    /**
    Returns the cumulative distance in meters for all motion types and in the specified timeframe.
     - Parameter motionType: the only motion type to consider.
     - Parameter from: starting date.
     - Parameter interval: interval to be added to the starting date.
     */
    public func distanceWithinIntervalAll(from: Date, interval: TimeInterval) throws -> Double {
        var total = 0.0
        for motion in MeasuredActivity.MotionType.allCases {
            total += try distanceWithinInterval(motionType: motion, from: from, interval: interval)
        }
        return total
    }
    
    /**
    Returns the cumulative carbon output in kg for the given motion type and in the specified timeframe.
     - Parameter motionType: the only motion type to consider.
     - Parameter from: starting date.
     - Parameter interval: interval to be added to the starting date.
     */
    public func carbonWithinInterval(motionType: MeasuredActivity.MotionType, from: Date, interval: TimeInterval) throws -> Double {
        let distance = try distanceWithinInterval(motionType: motionType, from: from, interval: interval)
        let carbonValue = computeCarbonUsage(distance: distance, type: motionType)

        return carbonValue
    }
    
    /**
    Returns the cumulative carbon output in kg for all motion types and in the specified timeframe.
     - Parameter motionType: the only motion type to consider.
     - Parameter from: starting date.
     - Parameter interval: interval to be added to the starting date.
     */
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
            let activityScore = UserScore(activity: activity, league: "", date: Date.dateToInternationalString(Date()))
            let oldTotalPoints = queryResult[0].value(forKey: "score") as! Double
            queryResult[0].setValue(oldTotalPoints + activityScore.totalPoints!, forKey: "score")
            queryResult[0].setValue(activityScore.date!, forKey: "dateStr")
        }

        try managedContext.save()
    }
    
    /// Updates league attribute of the Score entity with the given string.
    public func updateLeague(newLeague: String) throws {
       let managedContext = try getManagedContext()
       let dateToday = Date()
       let dateTodayStr = Date.dateToInternationalString(dateToday)
    
       // retrieve current userscore
        let queryResult = try executeQuery(entity: "Score", predicate: nil, args: nil) as! [NSManagedObject]
        if queryResult.count != 0 {
           queryResult[0].setValue(newLeague, forKey: "league")
           queryResult[0].setValue(dateTodayStr, forKey: "dateStr")
        }
    
        try managedContext.save()
    }
    
    /**
    Retrieves the latest UserScore in the Score entity. If no score if present, it is initialized with a default value.
    - Remark: Initial value is described in UserScore.getInitialScore()
    - Returns: A UserScore object having its properties set to the values in the database.
     */
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
    
    /// Returns the earliest start date within the Event entity. If no date is found, the date of today is returned.
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
    
    /**
     Returns the carbon output produced in the given hours for the current day and for the given motion type.
     - Remark: hours should be given in the format HH:mm:ss.
    */
    public func queryHourlyCarbon(motionType: MeasuredActivity.MotionType, hourStart: String, hourEnd: String) throws -> Double {
        let startDate = Date.setDateToSpecificHour(date: Date(), hour: hourStart)!
        let endDate = Date.setDateToSpecificHour(date: Date(), hour: hourEnd)!
        let timeInterval = endDate.timeIntervalSince(startDate)
        return try carbonWithinInterval(motionType: motionType, from: startDate, interval: timeInterval)
    }

    /**
     Returns the carbon output produced in the given hours for the current day.
     - Remark: hours should be given in the format HH:mm:ss.
     */
    public func queryHourlyCarbonAll(hourStart: String, hourEnd: String) throws -> Double {
        let startDate = Date.setDateToSpecificHour(date: Date(), hour: hourStart)!
        let endDate = Date.setDateToSpecificHour(date: Date(), hour: hourEnd)!
        let timeInterval = endDate.timeIntervalSince(startDate)
        return try carbonWithinIntervalAll(from: startDate, interval: timeInterval)
    }

    /**
     Returns the carbon output produced in the given day for the current week and for the given motion type.
     - Remark: day should be given in full and in standard UK english.
     */
    public func queryDailyCarbon(motionType: MeasuredActivity.MotionType, weekDayToDisplay: String) throws -> Double {
        let date = Date.getDateFromWeekdayName(weekDayToDisplay: weekDayToDisplay)!
        return try carbonWithinInterval(motionType: motionType, from: date, interval: 24*60*60)
    }

    /**
    Returns the carbon output in kg produced in the given day for the current week.
    - Remark: day name should be given in full and in standard UK english.
    */
    public func queryDailyCarbonAll(weekDayToDisplay: String) throws -> Double {
        let date = Date.getDateFromWeekdayName(weekDayToDisplay: weekDayToDisplay)!
        return try carbonWithinIntervalAll(from: date, interval: 24*60*60)
    }

    /**
    Returns the carbon output in kg produced in the given month for the current year and for the given motion type.
    - Remark: month name should be given in full and in standard UK english.
    */
    public func queryMonthlyCarbon(motionType:MeasuredActivity.MotionType, month: String) throws -> Double {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        dateFormatter.locale = Locale(identifier: "en-UK")
        
        let firstOfMonth = Date.monthNameToFirstOfMonth(month: month)!
        let lastOfMonth = Date.setDateToSpecificHour(date: Date.getEndDayOfMonth(date: firstOfMonth), hour: "23:59:59")!
        
        let interval = lastOfMonth.timeIntervalSince(firstOfMonth)
        return try carbonWithinInterval(motionType: motionType, from: firstOfMonth, interval: interval)
    }

    /**
    Returns the carbon output in kg produced in the given month for the current year.
    - Remark: month name should be given in full and in standard UK english.
    */
    public func queryMonthlyCarbonAll(month: String) throws -> Double {
        var carbonTotal : Double = 0
        for motion in MeasuredActivity.MotionType.allCases {
            if motion != .unknown {
                carbonTotal += try queryMonthlyCarbon(motionType: motion, month: month)
            }
        }
        return carbonTotal
    }
    
    /**
    Returns the carbon output in kg produced in the given year and for the given motion type.
    - Remark: year should be given in the format yyyy.
    */
    public func queryYearlyCarbon(motionType: MeasuredActivity.MotionType, year: String) throws -> Double {
        let yearStart = year + "-01-01 00:00:00 +0000"
        let yearEnd = year + "-12-31 23:59:59 +0000"

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        dateFormatter.locale = Locale(identifier: "en-UK")
        
        let startDate = dateFormatter.date(from: yearStart)!
        let endDate = dateFormatter.date(from: yearEnd)!
        
        let interval = endDate.timeIntervalSince(startDate)
        return try carbonWithinInterval(motionType: motionType, from: startDate, interval: interval)
    }
    
    /**
    Returns the carbon output in kg produced in the given year.
    - Remark: year should be given in the format yyyy.
    */
    public func queryYearlyCarbonAll(year: String) throws -> Double {
        var carbonTotal : Double = 0
        for motion in MeasuredActivity.MotionType.allCases {
            if motion != .unknown {
                carbonTotal += try queryYearlyCarbon(motionType: motion, year: year)
            }
        }
        return carbonTotal
    }
    
    /**
     Returns the carbon output in kg produced for the given distance and for the given motion type.
     - Parameter distance: distance in meters.
     - Parameter type: the only motion type to consider.
     */
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
}
