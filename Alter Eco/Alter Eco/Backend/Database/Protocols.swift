import Foundation
import SwiftUI
import CoreData

/// Represents an interface for a reader of Alter Eco's databases.
public protocol DBReader {
    /**
    Queries the Event entity with a predicate.
    - Parameter predicate: predicate used to select rows.
    - Parameter args: list of arguments to include in the predicate.
    - Returns: A list of activities that satisfy the predicate.
    */
    func queryActivities(predicate: String?, args: [Any]?) throws -> [MeasuredActivity]
    
    /**
    Queries the FoodProduct entity with a predicate.
    - Parameter predicate: predicate used to select rows.
    - Parameter args: list of arguments to include in the predicate.
    - Returns: A list of food products that satisfy the predicate.
    */
    func queryFoods(predicate: String?, args: [Any]?) throws -> [Food]
    
    /**
     Retrieves the carbon equivalent associated with the foods satisfying the given predicate.
     - Parameter predicate: predicate used to select rows.
     - Parameter args: list of arguments to include in the predicate.
     - Returns: The carbon equivalent value in kg.
     */
    func carbonFromFoods(predicate: String?, args: [Any]?) throws -> Measurement<UnitMass>
    
    /**
     Retrieves the carbon equivalent associated with the polluting items (e.g. food, transport activities) within the given interval.
     - Parameter from: the starting date.
     - Parameter addingInterval: the interval added to the starting date.
     - Returns: The carbon equivalent value in kg.
     */
    func carbonWithinInterval(from date: Date, addingInterval interval: Double) throws -> Measurement<UnitMass>
    
    /// Returns all forest items contained in the database. Only items with non-nil attributes are returned.
    func getForestItems() throws -> [ForestItem]
    
    /// Returns the score attribute in the Score entity.
    func retrieveLatestScore() throws -> Double
    
    /// Returns the earliest start date within the Event entity.
    func getFirstDate() throws -> Date?
    
    /**
    Queries the given entity with a predicate.
    - Parameter entity: entity name as a string.
    - Parameter predicate: predicate used to select rows.
    - Parameter args: list of arguments to include in the predicate.
    - Returns: A list of objects that satisfy the predicate.
    */
    func executeQuery(entity: String, predicate: String?, args:[Any]?) throws -> [Any]
}

/// Represents an interface for a writer of Alter Eco's databases.
public protocol DBWriter {
    /// Sets properties of the receiver entity with values from a given dictionary, using its keys to identify the properties.
    func setValuesForKeys(entity: String, keyedValues: [String : Any]) throws
    /// Appends an activity to the Event entity.
    func append(activity: MeasuredActivity) throws
    /// Appends a list of food products to the FoodProduct entity.
    func append(foods: [Food]) throws
    /// Updates the score to a given value.
    func updateScore(toValue value: Double) throws
    /// Deletes an entry from the given entity identified by a rows number.
    func delete(entity: String, rowNumber: Int) throws
    /// Deletes all entries in the given entity.
    func deleteAll(entity: String) throws
    /// Adds a function to be called whenever potentially polluting items (e.g. transport activities or foods) are written to the database.
    func addNewPollutingItemCallback(callback: @escaping (PollutingItemType) -> Void)
}

/// Represents an item which is potentially polluting.
public enum PollutingItemType {
    /// Specifies the item is food.
    case food
    /// Specifies the item is a transport activity.
    case transportActivity
}

/// Represents an interface to an object able to read, write and perform sophisticated queries on Alter Eco's databases.
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
    Returns the cumulative carbon output in kg for all polluting motion types and in the specified timeframe.
     - Parameter from: starting date.
     - Parameter interval: interval to be added to the starting date.
     - Remark: walking is considered not polluting and does not contribute to the returned value.
     */
    func carbonFromPollutingMotions(from: Date, interval: TimeInterval) throws -> Double
    
    /// Writes updates the entry associated with the id of the given forest item if it exists. Otherwise, a new item is written to the database.
    func saveForestItem(_ item: ForestItem) throws
    /// Updates the score by adding the score computed from a given activity.
    func updateScore(activity: MeasuredActivity) throws
}
