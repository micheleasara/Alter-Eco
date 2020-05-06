import Foundation

/// Represents a list of activities connected to a database.
public protocol ActivityList : AnyObject, MutableCollection
where Index == Int, Element == Array<MeasuredActivity>.Element {
    /// Adds the given activity to the list.
    func add(_ activity:MeasuredActivity)
    /// Remove the element at the given index.
    func remove(at:Index)
    /// Removes all elements.
    func removeAll()
    /// Writes to the database the activity resulting from the measurements in the given range, and then deletes them.
    func dumpToDatabase(from:Int, to:Int)
    /// Writes to the database the activity resulting from the measurements in the given range.
    func writeToDatabase(from:Int, to:Int)
}


/// A list of activities which can store activities in memory and then write their weighted average to a database.
public class WeightedActivityList: ActivityList {
    public typealias Index = Array<MeasuredActivity>.Index
    public typealias Element = Array<MeasuredActivity>.Element
    public typealias Iterator = Array<MeasuredActivity>.Iterator
    private var measurements: [MeasuredActivity] = []
    // the upper and lower bounds of the collection, used in iterations
    public var startIndex: Index { return measurements.startIndex }
    public var endIndex: Index { return measurements.endIndex }
    private let activityWeights: [MeasuredActivity.MotionType: Int]
    private let DBMS: DBWriter
    
    /**
     Initializes A list of activities which can store activities in memory and then write their weighted average to a database.
     - Parameter activityWeights: dictionary associating a motion type to a weight.
     - Parameter DBMS: object to write to the database.
     */
    init(activityWeights: [MeasuredActivity.MotionType: Int], DBMS: DBWriter) {
        self.activityWeights = activityWeights
        self.DBMS = DBMS
    }
    
    /// Returns an iterator over the elements of the collection.
    public __consuming func makeIterator() -> Iterator {
        return measurements.makeIterator()
    }
    
    /// Accesses the element at the specified position.
    public subscript(index: Index) -> Iterator.Element {
        get { return measurements[index] }
        set { measurements[index] = newValue}
    }

    /// Returns the next index when iterating.
    public func index(after i: Index) -> Index {
        return measurements.index(after: i)
    }
    
    /// Removes an element at the specified position.
    public func remove(at: Index) {
        measurements.remove(at: at)
    }

    /// Adds the given activity.
    public func add(_ activity: MeasuredActivity) {
        if activity.motionType == .plane || activity.motionType == .train {
            writeToDatabase(activity)
            removeAll()
        } else {
            measurements.append(activity)
        }
    }
    
    /// Returns the weighted average of the activities between the given indexes.
    public func getAverage(from:Int, to:Int) -> MeasuredActivity {
        let activity = MeasuredActivity(motionType: getAverageMotionType(from:from, to:to),
                                        distance: getCumulativeDistance(from:from, to:to),
                                        start: measurements.first!.start, end: measurements.last!.end)
        return activity
    }

    /// Returns the cumulative distance contained in the activities in the range provided.
    public func getCumulativeDistance(from:Int, to:Int) -> Double {
        var distance = 0.0
        for i in stride(from: from, through: to, by: 1) {
            distance += measurements[i].distance
        }
        return distance
    }
    
    /// Returns the average motion type determined by the activities in the range provided.
    public func getAverageMotionType(from:Int, to: Int) -> MeasuredActivity.MotionType {
        if measurements.count <= 0 { return .unknown }
        if measurements.count == 1 { return measurements[0].motionType }
        
        // compute weighted average
        var carCounter = 0
        var walkingCounter = 0
        for i in stride(from: from, through: to, by: 1) {
            if measurements[i].motionType == .car {
                carCounter += 1
            }
            else {
                walkingCounter += 1
            }
        }
        
        var motion : MeasuredActivity.MotionType
        if carCounter * activityWeights[.car]! >= walkingCounter * activityWeights[.walking]! {
            motion = .car
        }
        else {
            motion = .walking
        }
        return motion
    }
    
    /// Removes all activities.
    public func removeAll() {
        measurements.removeAll()
    }
    
    /// Writes to the database the average of the activities in the range provided, then deletes them.
    public func dumpToDatabase(from:Int, to:Int) {
        writeToDatabase(from:from, to:to)
        measurements.removeSubrange(from...to)
    }
    
    /// Writes to the database the average of the activities in the range provided.
    public func writeToDatabase(from: Int, to: Int) {
        if measurements.count > 0 {
            writeToDatabase(getAverage(from: from, to: to))
        }
    }
    
    private func writeToDatabase(_ activity: MeasuredActivity){
        try! DBMS.append(activity: activity)
        try! DBMS.updateScore(activity: activity)
    }
}
