import Foundation
import SwiftUI
import CoreData

/// Represents a database manager that provides an I/O interface with the CoreData framework. Also provides carbon conversion utilities.
public class CoreDataManager : DBManager, CarbonCalculator {
    // contains the function called when an activity has been written to the database
    private var activityWrittenCallbacks: [(MeasuredActivity) -> Void] = []
    // contains the function called when a list of foods has been written to the database
    private var foodsWrittenCallbacks: [([Food]) -> Void] = []
    
    public func addActivityWrittenCallback(callback: @escaping (MeasuredActivity) -> Void) {
        self.activityWrittenCallbacks.append(callback)
    }
    
    public func addFoodsWrittenCallback(callback: @escaping ([Food]) -> Void) {
        self.foodsWrittenCallbacks.append(callback)
    }
    
    public func append(foods: [Food]) throws {
        for food in foods {
            try setValuesForKeys(entity: "FoodProduct",
                                 keyedValues:
                ["barcode" : food.barcode,
                 "name": food.name as Any,
                 "type": food.types?.first as Any,
                 "date": Date().toLocalTime(),
                 "quantityValue": food.quantity?.value as Any,
                 "quantityUnit": food.quantity?.unit.symbol as Any,
                 "category": food.category?.rawValue as Any])
        }
        for callback in foodsWrittenCallbacks {
            callback(foods)
        }
    }
    
    public func append(activity: MeasuredActivity) throws {
        try setValuesForKeys(entity: "Event",
                             keyedValues:
            ["motionType" : MeasuredActivity.motionTypeToString(type: activity.motionType),
             "distance": activity.distance,
             "start": activity.start,
             "end": activity.end])
        
        // call registered observers with the activity just written
        for callback in activityWrittenCallbacks {
            callback(activity)
        }
    }
    
    public func setValuesForKeys(entity: String, keyedValues: [String : Any]) throws {
        let managedContext = try getManagedContext()
        let entity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)!
        let db = NSManagedObject(entity: entity, insertInto: managedContext)
        db.setValuesForKeys(keyedValues)
        try managedContext.save()
    }
    
    public func deleteAll(entity: String) throws {
        let results = try executeQuery(entity: entity) as? [NSManagedObject] ?? []
        for result in results {
            try delete(result)
        }
    }
    
    public func delete(entity: String, rowNumber: Int) throws {
        let results = try executeQuery(entity: entity) as? [NSManagedObject] ?? []
        if results.count > rowNumber {
            try delete(results[rowNumber])
        }
    }
    
    public func carbonFromPollutingMotions(from: Date, interval: TimeInterval) throws -> Double {
        var carbonTotal : Double = 0
        for motion in MeasuredActivity.MotionType.allCases {
            if motion.isPolluting() {
                carbonTotal += try carbonWithinInterval(motionType: motion, from: from, interval: interval)
            }
        }
        
        return carbonTotal
    }
    
    public func carbonWithinInterval(motionType: MeasuredActivity.MotionType, from: Date, interval: TimeInterval) throws -> Double {
        let distance = try distanceWithinInterval(motionType: motionType, from: from, interval: interval)
        let carbonValue = computeCarbonUsage(distance: distance, type: motionType)

        return carbonValue
    }
    
    public func distanceWithinIntervalAll(from: Date, interval: TimeInterval) throws -> Double {
        var total = 0.0
        for motion in MeasuredActivity.MotionType.allCases {
            total += try distanceWithinInterval(motionType: motion, from: from, interval: interval)
        }
        return total
    }
    
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
    
    public func queryActivities(predicate: String? = nil, args: [Any]? = nil) throws -> [MeasuredActivity] {
        var measuredActivities = [MeasuredActivity]()
        let queryResult = (try executeQuery(entity: "Event", predicate: predicate, args: args)) as? [NSManagedObject] ?? []

        for result in queryResult {
            let motionType = MeasuredActivity.stringToMotionType(type: result.value(forKey: "motionType") as! String)
            let distance = result.value(forKey: "distance") as! Double
            let start = result.value(forKey: "start") as! Date
            let end = result.value(forKey: "end") as! Date
            measuredActivities.append(MeasuredActivity(motionType: motionType, distance: distance, start: start, end: end))
        }
        
        return measuredActivities
    }
    
    public func queryFoods(predicate: String?, args: [Any]?) throws -> [Food] {
        var foods = [Food]()
        let queryResult = (try executeQuery(entity: "FoodProduct", predicate: predicate, args: args)) as? [NSManagedObject] ?? []

        for result in queryResult {
            let barcode = result.value(forKey: "barcode") as! String
            let name = result.value(forKey: "name") as! String?
            let type = result.value(forKey: "type") as! String?
            let types: [String]? = (type == nil) ? nil : [type!]
            let quantityValue = result.value(forKey: "quantityValue") as? Double ?? 0
            let quantityUnit = result.value(forKey: "quantityUnit") as? String ?? ""
            let quantity = Food.Quantity(value: quantityValue, unit: quantityUnit)
            foods.append(Food(barcode: barcode, name: name, quantity: quantity, types: types, image: nil))
        }
        
        return foods
    }
    
    public func updateScore(activity: MeasuredActivity) throws {
        let managedContext = try getManagedContext()

        // retrieve current score
        let queryResult = try executeQuery(entity: "Score") as? [NSManagedObject] ?? []
        if queryResult.count != 0 {
            let activityScore = UserScore(activity: activity, league: "", date: Date().toLocalTime().toInternationalString(), counter: 0)
            let oldTotalPoints = queryResult[0].value(forKey: "score") as! Double
            queryResult[0].setValue(oldTotalPoints + activityScore.totalPoints!, forKey: "score")
            queryResult[0].setValue(activityScore.date!, forKey: "dateStr")
        }

        try managedContext.save()
    }
    
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
    
    public func updateLeague(newLeague: String) throws {
       let managedContext = try getManagedContext()
       let dateToday = Date().toLocalTime()
       let dateTodayStr = dateToday.toInternationalString()
    
       // retrieve current user's score
        let queryResult = try executeQuery(entity: "Score") as? [NSManagedObject] ?? []
        if queryResult.count != 0 {
           queryResult[0].setValue(newLeague, forKey: "league")
           queryResult[0].setValue(dateTodayStr, forKey: "dateStr")
        }
    
        try managedContext.save()
    }
    
    public func retrieveLatestScore() throws -> UserScore {
        let userScore = UserScore.getInitialScore()

        let queryResult = try executeQuery(entity: "Score") as? [NSManagedObject] ?? []
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
    
    /// Returns the earliest start date within the Event entity. If no date is found, the current date is returned.
    public func getFirstDate() throws -> Date {
        var oldDate = Date().toLocalTime()
        let managedContext = try getManagedContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        let queryResult = try managedContext.fetch(fetchRequest)
        if queryResult.count != 0 {
            oldDate = queryResult[0].value(forKey: "start") as? Date ?? oldDate
        }
        return oldDate
    }
    
    public func executeQuery(entity: String, predicate: String? = nil, args: [Any]? = nil) throws -> [Any] {
        let managedContext = try getManagedContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        if predicate != nil && args != nil {
            fetchRequest.predicate = NSPredicate(format: predicate!, argumentArray: args!)
        }
        let queryResult = try managedContext.fetch(fetchRequest)

        return queryResult
    }
    
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
    
    /// Returns a container that encapsulates the Core Data stack.
    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Database2.0")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    /// Returns a programmatic representation of the .xcdatamodeld file.
    public lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
        return managedObjectModel
    }()
    
    /// Deletes the object given.
    private func delete(_ obj: NSManagedObject) throws {
        let context = try getManagedContext()
        context.delete(obj)
    }
    
    /// Sets the user's score to 0.
    private func resetScore() throws -> Void {
        let managedContext = try getManagedContext()
        let dateToday = Date().toLocalTime()
        let dateTodayStr = dateToday.toInternationalString()
        
        let newScore = 0.0
        
        let queryResult = try executeQuery(entity: "Score") as? [NSManagedObject] ?? []
        if queryResult.count != 0 {
            queryResult[0].setValue(newScore, forKey: "score")
            queryResult[0].setValue(dateTodayStr, forKey: "dateStr")
        }
        
        try managedContext.save()
    }
    
    private func updateTreeCounter() throws -> Void {
           let managedContext = try getManagedContext()
           let dateToday = Date().toLocalTime()
           let dateTodayStr = dateToday.toInternationalString()
           
           let queryResult = try executeQuery(entity: "Score") as? [NSManagedObject] ?? []
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

// needed to avoid default NSManagedObject warning
@objc(ProfilePic)
public class ProfilePic: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfilePic> {
        return NSFetchRequest<ProfilePic>(entityName: "ProfilePic")
    }

    @NSManaged public var imageP: Data?
}
