import Foundation
import SwiftUI
import CoreData

/// Represents a database manager that provides an I/O interface with the CoreData framework.
public class CoreDataManager: DBManager {
    public func delete(entity: String, predicate: String?, args: [Any]?) throws {
        if let results = try executeQuery(entity: entity, predicate: predicate, args: args) as? [NSManagedObject] {
            for result in results {
                try delete(result)
            }
        }
        
    }
    
    // utility to get carbon from food items
    private let foodConverter: FoodToCarbonConverter

    // contains the functions called when an activity or a food has been written to the database
    private var newPollutingItemCallbacks: [(PollutingItemType) -> Void] = []
    
    public init(foodConverter: FoodToCarbonConverter = FoodToCarbonManager()) {
        self.foodConverter = foodConverter
    }
    
    public func addNewPollutingItemCallback(callback: @escaping (PollutingItemType) -> Void) {
        newPollutingItemCallbacks.append(callback)
    }
    
    
    public func append(foods: [Food], withDate date: Date = Date() ) throws {
        for food in foods {
            try setValuesForKeys(entity: "FoodProduct",
                                 keyedValues:
                ["barcode" : food.barcode,
                 "name": food.name as Any,
                 "type": food.types?.first as Any,
                 "date": date,
                 "quantityValue": food.quantity?.value as Any,
                 "quantityUnit": food.quantity?.unit.symbol as Any,
                 "category": food.getCategory(using: FoodToCarbonManager.self)?.rawValue as Any])
        }
        for callback in newPollutingItemCallbacks {
            callback(.food)
        }
    }
    
    public func append(activity: MeasuredActivity) throws {
        try setValuesForKeys(entity: "Event",
                             keyedValues:
            ["motionType" : MeasuredActivity.motionTypeToString(type: activity.motionType),
             "distance": activity.distance,
             "start": activity.start,
             "end": activity.end])
        
        for callback in newPollutingItemCallbacks {
            callback(.transportActivity)
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
    
    public func carbonFromFoods(predicate: String?, args: [Any]?) throws -> Measurement<UnitMass> {
        let foods = try queryFoods(predicate: predicate, args: args)
        return foodConverter.getCarbon(fromFoods: foods)
    }
    
    public func carbonWithinInterval(from date: Date, addingInterval interval: Double) throws -> Measurement<UnitMass> {
        let end = date.addingTimeInterval(DAY_IN_SECONDS)
        let transport = try carbonFromPollutingMotions(from: date, interval: DAY_IN_SECONDS)
        let foods = try carbonFromFoods(predicate: "date >= %@ AND date <= %@", args: [date, end]).value
        
        return Measurement(value: transport + foods, unit: .kilograms)
    }
    
    public func updateScore(activity: MeasuredActivity) throws {
        let managedContext = try getManagedContext()
        let currentScore = try retrieveLatestScore()
        try updateScore(toValue: currentScore + activity.equivalentPoints)

        try managedContext.save()
    }
    
    public func updateScore(toValue value: Double) throws {
        // retrieve current score
        let queryResult = try executeQuery(entity: "Score") as? [NSManagedObject] ?? []
        if let result = queryResult.first {
            result.setValue(value, forKey: "score")
        } else { // initialize score
            try setValuesForKeys(entity: "Score", keyedValues: ["score": value])
        }
    }
    
    public func saveForestItem(_ item: ForestItem) throws {
        if let fetched = (try executeQuery(entity: "ForestItems",
                                        predicate: "uuid == %@", args: [item.id]) as? [NSManagedObject])?.first {
            fetched.setValue(item.x, forKey: "x")
            fetched.setValue(item.y, forKey: "y")
            fetched.setValue(item.z, forKey: "z")
            fetched.setValue(item.internalName, forKey: "internalName")
            try getManagedContext().save()
        } else {
            try setValuesForKeys(entity: "ForestItems",
                                 keyedValues: ["internalName": item.internalName,
                                               "x": item.x, "y": item.y, "z": item.y,
                                               "uuid": item.id])
        }
    }
    
    public func getForestItems() throws -> [ForestItem] {
        guard let items = try executeQuery(entity: "ForestItems", predicate: nil, args: nil) as? [NSManagedObject] else { return [] }
        
        var validItems: [ForestItem] = []
        for item in items {
            if let uuid = item.value(forKey: "uuid") as? String,
                let internalName = item.value(forKey: "internalName") as? String,
                let x = item.value(forKey: "x") as? Float,
                let y = item.value(forKey: "y") as? Float,
                let z = item.value(forKey: "z") as? Float {
                validItems.append(ForestItem(id: uuid, x: x, y: y, z: z, internalName: internalName))
            }
        }
        
        return validItems
    }
    
    public func retrieveLatestScore() throws -> Double {
        var userScore = 0.0

        let queryResult = try executeQuery(entity: "Score") as? [NSManagedObject] ?? []
        if let result = queryResult.first {
            userScore = (result.value(forKey: "score") as? Double) ?? 0
        }
        
        return userScore
    }
    
    /// Returns the earliest start date within the Event entity. If no date is found, nil is returned.
    public func getFirstDate() throws -> Date? {
        let managedContext = try getManagedContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        let queryResult = try managedContext.fetch(fetchRequest)
        if let result = queryResult.first {
            return result.value(forKey: "start") as? Date ?? nil
        }
        return nil
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
