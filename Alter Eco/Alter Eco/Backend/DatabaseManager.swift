import Foundation
import SwiftUI
import CoreData


//all the constants for carbon conversions come from:
//https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2019
//all units below have been converted to kgrams/kilometer

/// Represents an interface for a reader of Alter Eco's databases.
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

/// Represents an interface for a writer of Alter Eco's databases.
public protocol DBWriter {
    /// Sets properties of the receiver entity with values from a given dictionary, using its keys to identify the properties.
    func setValuesForKeys(entity: String, keyedValues: [String : Any]) throws
    /// Appends an activity to the Event entity.
    func append(activity: MeasuredActivity) throws
    /// Updates score by adding score computed from a given activity.
    func updateScore(activity: MeasuredActivity) throws
}

/// Represents an interface to an object able to read, write and perform sophisticated queries on AlterEco's databases.
public protocol DBManager : AnyObject, DBReader, DBWriter {
    /// Adds a function to be called whenever something is written to the database.
    func setActivityWrittenCallback(callback: @escaping (MeasuredActivity) -> Void) 

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
    Returns the cumulative carbon output in kg for all polluting motion types and in the specified timeframe.
     - Parameter from: starting date.
     - Parameter interval: interval to be added to the starting date.
     - Remark: walking is considered not polluting and does not contribute to the returned value.
     */
    func carbonFromPollutingMotions(from: Date, interval: TimeInterval) throws -> Double
    
    /// Updates the league attribute of the Score entity with the given string.
    func updateLeague(newLeague: String) throws
    /**
    Retrieves the latest UserScore in the Score entity. If no score if present, it is initialized with a default value.
    - Remark: Initial value is described in UserScore.getInitialScore()
    - Returns: A UserScore object having its properties set to the values in the database.
     */
    func retrieveLatestScore() throws -> UserScore
    /**
    Checks user progress and updates league if enough points have been accumulated.
     */
    func updateLeagueIfEnoughPoints() throws -> Void
    
    /// Returns the earliest start date within the Event entity.
    func getFirstDate() throws -> Date
}

public protocol CarbonCalculator {
    /// Returns the carbon output produced for the given distance and for the given motion type.
    func computeCarbonUsage(distance:Double, type: MeasuredActivity.MotionType) -> Double
}


/// Represents a database manager that provides an I/O interface with the CoreData framework. Also provides carbon conversion utilities.
public class CoreDataManager : DBManager, CarbonCalculator {
    // contains Core Data's stack
    private let persistentContainer : NSPersistentContainer
    // contains the function called when an activity has been written to the database
    private var activityWrittenCallback : (MeasuredActivity) -> Void = {_ in }
    
    /**
    Initializes a new database manager that interacts with the Core Data framework.
    - Parameter persistentContainer: A container that encapsulates the Core Data stack.
    */
    public init(persistentContainer : NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    /// Sets a callback function which is called whenever an activity is added.
    public func setActivityWrittenCallback(callback: @escaping (MeasuredActivity) -> Void) {
        self.activityWrittenCallback = callback
    }
    
    /**
    Queries the given entity with a predicate.
    - Parameter entity: entity name as string.
    - Parameter predicate: Predicate used to select rows.
    - Parameter args: List of arguments to include in the predicate.
    - Returns: List of objects that satisfy the predicate.
    - Remark: See .xcdatamodeld file for information about valid entities.
    */
    public func executeQuery(entity: String, predicate: String? = nil, args: [Any]? = nil) throws -> [Any] {
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
    public func queryActivities(predicate: String? = nil, args: [Any]? = nil) throws -> [MeasuredActivity] {
        var measuredActivities = [MeasuredActivity]()
        let queryResult = (try executeQuery(entity: "Event", predicate: predicate, args: args)) as! [NSManagedObject]

        for result in queryResult {
            let motionType = MeasuredActivity.stringToMotionType(type: result.value(forKey: "motionType") as! String)
            let distance = result.value(forKey: "distance") as! Double
            let start = result.value(forKey: "start") as! Date
            let end = result.value(forKey: "end") as! Date
            measuredActivities.append(MeasuredActivity(motionType: motionType, distance: distance, start: start, end: end))
        }
        
        return measuredActivities
    }
    
    /// Sets properties of the receiver entity with values from a given dictionary, using its keys to identify the properties.
    public func setValuesForKeys(entity: String, keyedValues: [String : Any]) throws {
        let managedContext = try getManagedContext()
        let entity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)!
        let db = NSManagedObject(entity: entity, insertInto: managedContext)
        db.setValuesForKeys(keyedValues)
        try managedContext.save()
    }
    
    /// Appends an activity to the Event entity.
    public func append(activity: MeasuredActivity) throws {
        try setValuesForKeys(entity: "Event", keyedValues: ["motionType" : MeasuredActivity.motionTypeToString(type: activity.motionType), "distance":activity.distance, "start":activity.start, "end":activity.end])
        
        // call registered observer with the activity just written
        activityWrittenCallback(activity)
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
        let queryMeasuredActivities = try queryActivities(predicate: "motionType == %@ AND ((start <= %@ AND end > %@) OR (start >= %@ AND start < %@))", args: [motionString as NSString, from as NSDate, from as NSDate, from as NSDate, endDate as NSDate])

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
    Returns the cumulative carbon output in kg for all polluting motion types and in the specified timeframe.
     - Parameter from: starting date.
     - Parameter interval: interval to be added to the starting date.
     - Remark: walking is considered not polluting and does not contribute to the returned value.
     */
    public func carbonFromPollutingMotions(from: Date, interval: TimeInterval) throws -> Double {
        var carbonTotal : Double = 0
        for motion in MeasuredActivity.MotionType.allCases {
            if motion.isPolluting() {
                carbonTotal += try carbonWithinInterval(motionType: motion, from: from, interval: interval)
            }
        }
        
        return carbonTotal
    }
    
    /// Updates score by adding score computed from a given activity.
    public func updateScore(activity: MeasuredActivity) throws {
        let managedContext = try getManagedContext()

        // retrieve current score
        let queryResult = try executeQuery(entity: "Score") as! [NSManagedObject]
        if queryResult.count != 0 {
            let activityScore = UserScore(activity: activity, league: "", date: Date.toInternationalString(Date().toLocalTime()), counter: 0)
            let oldTotalPoints = queryResult[0].value(forKey: "score") as! Double
            queryResult[0].setValue(oldTotalPoints + activityScore.totalPoints!, forKey: "score")
            queryResult[0].setValue(activityScore.date!, forKey: "dateStr")
        }

        try managedContext.save()
    }
    
    /// Checks user progress and updates league if enough points have been accumulated.
    public func updateLeagueIfEnoughPoints() throws -> Void {
        let userScore = try retrieveLatestScore()
        
        if userScore.totalPoints > POINTS_REQUIRED_FOR_NEXT_LEAGUE {
            let league = UserScore.getNewLeague(userLeague: userScore.league)
            try updateLeague(newLeague: league)
            
            if league == "🌳" {
                try updateTreeCounter()
            }
            
            try resetScore()
        }
    }
    
    /// Updates league attribute of the Score entity with the given string.
    public func updateLeague(newLeague: String) throws {
       let managedContext = try getManagedContext()
       let dateToday = Date().toLocalTime()
       let dateTodayStr = Date.toInternationalString(dateToday)
    
       // retrieve current user's score
        let queryResult = try executeQuery(entity: "Score") as! [NSManagedObject]
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

        let queryResult = try executeQuery(entity: "Score") as! [NSManagedObject]
        if queryResult.count != 0 {
            userScore.totalPoints = queryResult[0].value(forKey: "score") as? Double
            userScore.date = queryResult[0].value(forKey: "dateStr") as? String
            userScore.league = queryResult[0].value(forKey: "league") as? String
            userScore.counter = queryResult[0].value(forKey: "counter") as? Int
        } else {
            try setValuesForKeys(entity: "Score", keyedValues: ["dateStr": userScore.date!, "score": userScore.totalPoints!, "league": userScore.league!, "counter": userScore.counter!])
        }
        
        return userScore
    }
    
    /// Sets the user's score to 0.
    private func resetScore() throws -> Void {
        let managedContext = try getManagedContext()
        let dateToday = Date().toLocalTime()
        let dateTodayStr = Date.toInternationalString(dateToday)
        
        let newScore = 0.0
        
        let queryResult = try executeQuery(entity: "Score") as! [NSManagedObject]
        if queryResult.count != 0 {
            queryResult[0].setValue(newScore, forKey: "score")
            queryResult[0].setValue(dateTodayStr, forKey: "dateStr")
        }
        
        try managedContext.save()
    }
    
    /// Returns the earliest start date within the Event entity. If no date is found, the date of today is returned.
    public func getFirstDate() throws -> Date {
        var oldDate = Date().toLocalTime()
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
    
    private func updateTreeCounter() throws -> Void {
           let managedContext = try getManagedContext()
           let dateToday = Date().toLocalTime()
           let dateTodayStr = Date.toInternationalString(dateToday)
           
           let queryResult = try executeQuery(entity: "Score") as! [NSManagedObject]
           if queryResult.count != 0 {
               let oldCounter = queryResult[0].value(forKey: "counter") as! Int
               queryResult[0].setValue(oldCounter + 1, forKey: "counter")
               queryResult[0].setValue(dateTodayStr, forKey: "dateStr")
           }
           try managedContext.save()
       }
    
    private func getManagedContext() throws -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
