import Foundation

public protocol ActivityList : AnyObject, MutableCollection {
    func add(_ activity:MeasuredActivity)
    func remove(at:Index)
    func removeAll()
    func dumpToDatabase(from:Int, to:Int)
}

public class WeightedActivityList: ActivityList {
    public typealias Index = Array<MeasuredActivity>.Index
    public typealias Element = Array<MeasuredActivity>.Element
    public typealias Iterator = Array<MeasuredActivity>.Iterator
    private var measurements: [MeasuredActivity] = []
    // the upper and lower bounds of the collection, used in iterations
    public var startIndex: Index { return measurements.startIndex }
    public var endIndex: Index { return measurements.endIndex }
    private let activityWeights: [MeasuredActivity.MotionType: Int]
    private let numChangeActivity: Int
    private let DBMS: DBManager
    
    init(activityWeights: [MeasuredActivity.MotionType: Int], numChangeActivity: Int, DBMS: DBManager) {
        self.activityWeights = activityWeights
        self.numChangeActivity = numChangeActivity
        self.DBMS = DBMS
    }
    
    // Returns an iterator over the elements of the collection
    public __consuming func makeIterator() -> Iterator {
        return measurements.makeIterator()
    }
    
    // Accesses the element at the specified position
    public subscript(index: Index) -> Iterator.Element {
        get { return measurements[index] }
        set { measurements[index] = newValue}
    }

    // Returns the next index when iterating
    public func index(after i: Index) -> Index {
        return measurements.index(after: i)
    }
    
    public func hasChangedSignificantly() -> Bool {
        if measurements.count <= numChangeActivity { return false }
        
        let rootType = measurements[0].motionType
        var previousLastType: MeasuredActivity.MotionType? = nil
        for index in stride(from: (measurements.count-numChangeActivity-1), to: measurements.count, by: 1) {
            let type = measurements[index].motionType
            if type == rootType || (previousLastType != nil && previousLastType != type) {
                return false
            }
            previousLastType = type
        }
        
        return true
    }
    
    public func remove(at: Index) {
        measurements.remove(at: at)
    }

    public func add(_ activity: MeasuredActivity) {
        if activity.motionType == .plane || activity.motionType == .train {
            writeToDatabase(activity)
            measurements.removeAll()
        } else {
            measurements.append(activity)
            if hasChangedSignificantly() {
                let newActivityIndex = measurements.count - numChangeActivity
                dumpToDatabase(from: 0, to: newActivityIndex - 1)
            }
        }
        
    }
    
    public func getAverage(from:Int, to:Int) -> MeasuredActivity {
        let activity = MeasuredActivity(motionType: getAverageMotionType(from:from, to:to),
                                        distance: getCumulativeDistance(from:from, to:to),
                                        start: measurements.first!.start, end: measurements.last!.end)
        return activity
    }

    public func getCumulativeDistance(from:Int, to:Int) -> Double {
        var distance = 0.0
        for i in stride(from: from, to: to, by: 1) {
            distance += measurements[i].distance
        }
        return distance
    }
    
    public func getAverageMotionType(from:Int, to: Int) -> MeasuredActivity.MotionType {
        var carCounter = 0
        var walkingCounter = 0

        for i in stride(from: from, to: to, by: 1) {
            if measurements[i].motionType == .car {
                carCounter += 1
            }
            else {
                walkingCounter += 1
            }
        }

        if carCounter * activityWeights[.car]! > walkingCounter {
            return .car
        }
        else {
            return .walking
        }
    }
    
    public func removeAll() {
        measurements.removeAll()
    }
    
    public func dumpToDatabase(from:Int, to:Int) {
        writeToDatabase(getAverage(from: from, to: to))
        measurements.removeSubrange(from...to)
    }
    
    private func writeToDatabase(_ activity: MeasuredActivity){
        do {
            try DBMS.append(activity: activity)
            try DBMS.updateScore(activity: activity)
        } catch {
            print("Could not write activity to database: \(error)")
        }
    }
}
