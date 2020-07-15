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
    /// Updates score by adding score computed from a given activity.
    func updateScore(activity: MeasuredActivity) throws
    /// Deletes an entry from the given entity identified by a rows number.
    func delete(entity: String, rowNumber: Int) throws
    /// Deletes all entries in the given entity.
    func deleteAll(entity: String) throws
}

/// Represents an interface to an object able to read, write and perform sophisticated queries on Alter Eco's databases.
public protocol DBManager : AnyObject, DBReader, DBWriter {
    /// Adds a function to be called whenever an activity is written to the database.
    func addActivityWrittenCallback(callback: @escaping (MeasuredActivity) -> Void)

    /// Adds a function to be called whenever foods are written to the database.
    func addFoodsWrittenCallback(callback: @escaping ([Food]) -> Void)

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
    
    ///Checks user progress and updates league if enough points have been accumulated.
    func updateLeagueIfEnoughPoints() throws -> Void
    
    /// Returns the earliest start date within the Event entity.
    func getFirstDate() throws -> Date
}

public protocol CarbonCalculator {
    /// Returns the carbon output produced for the given distance and for the given motion type.
    func computeCarbonUsage(distance:Double, type: MeasuredActivity.MotionType) -> Double
}
