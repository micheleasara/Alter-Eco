import Foundation

/// Represents a list of activities connected to a database.
public protocol ActivityList : AnyObject, MutableCollection
where Index == Int, Element == Array<MeasuredActivity>.Element {
    /// Uses the activities in the given range to synthesize one overall activity.
    func synthesize(from:Int, to:Int) -> MeasuredActivity
    /// Adds the given activity to the list.
    func add(_ activity:MeasuredActivity)
    /// Removes the element at the given index.
    func remove(at:Index)
    /// Removes the elements in the range specified.
    func remove(from:Index, to:Index)
    /// Removes all elements.
    func removeAll()
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
    private let activityWeights: [MeasuredActivity.MotionType: Double]
    
    /**
     Initializes A list of activities which can store activities in memory and then write their weighted average to a database.
     - Parameter activityWeights: dictionary associating a motion type to a weight.
     */
    init(activityWeights: [MeasuredActivity.MotionType: Double]) {
        self.activityWeights = activityWeights
    }
    
    /// Removes the elements in the range specified.
    public func remove(from: Index, to: Index) {
        for i in stride(from: from, through: to, by: 1) {
            remove(at: i)
        }
    }
    
    /// Uses the activities in the given range to synthesize one overall activity via weighted average.
    public func synthesize(from: Index, to: Index) -> MeasuredActivity {
        let averaged = getAverage(from: from, to: to)
        return averaged
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
        measurements.append(activity)
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
        var carCounter = 0.0
        var walkingCounter = 0.0
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
}
