import Foundation
import AlterEcoBackend

// MARK: Xcode does not offer any mocking package as of now (05/2020), so mocks are created manually

class DBWriterMock: DBWriter {
    func updateScore(toValue value: Double) throws {
    }
    
    func append(foods: [Food]) throws {
    }
    
    func append(food: Food) throws {}
    
    var appendArgs: [MeasuredActivity] = []
    
    func append(activity: MeasuredActivity) throws {
        appendArgs.append(activity)
    }
    
    func delete(entity: String, rowNumber: Int) throws {
    }
    
    func deleteAll(entity: String) throws {
    }
    
    func setValuesForKeys(entity: String, keyedValues: [String : Any]) throws {}
}

class MultiTimerMock: CountdownHandler {
    public var startCalls: Int = 0
    public var stopCalls: Int = 0
    public var startKeys: [String] = []
    public var startIntervals: [Double] = []
    public var startBlocks: [() -> Void] = []
    func start(key: String, interval: TimeInterval, block: @escaping () -> Void) {
        startCalls += 1
        startKeys.append(key)
        startIntervals.append(interval)
        startBlocks.append(block)
    }
    
    func stop(_ key: String) {}
}

class ActivityListMock : ActivityList {
    public var measurements: [MeasuredActivity] = []
    public typealias Index = Array<MeasuredActivity>.Index
    public typealias Element = Array<MeasuredActivity>.Element
    public typealias Iterator = Array<MeasuredActivity>.Iterator
    public var startIndex: Index { return measurements.startIndex }
    public var endIndex: Index { return measurements.endIndex }
    
    public var synthesizeCalls: Int = 0
    public var synthesizeArgs: [Int] = []
    public var addCalls: Int = 0
    public var addArgs: [MeasuredActivity] = []
    public var removeCalls: Int = 0
    public var removeAllCalls: Int = 0
    
    func synthesize(from: Int, to: Int) -> MeasuredActivity? {
        synthesizeArgs.append(from)
        synthesizeArgs.append(to)
        synthesizeCalls += 1
        // return a fake activity
        return MeasuredActivity(motionType: .unknown, distance: -1, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 1))
    }
    
    func remove(from: Index, to: Index) {
        for _ in stride(from: from, through: to, by: 1) {
            removeCalls += 1
        }
        measurements.removeSubrange(from...to)
    }
    
    func add(_ activity:MeasuredActivity) {
        measurements.append(activity)
        addArgs.append(activity)
        addCalls += 1
    }
    
    func remove(at:Index) {
        measurements.remove(at: at)
        removeCalls += 1
    }
    
    func removeAll() {
        remove(from: 0, to: count-1)
        removeAllCalls += 1
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
}

class DBManagerMock: DBWriterMock, DBManager {
    var carbonWithinIntervalMotionTypes = [MeasuredActivity.MotionType]()
    var carbonWithinIntervalFroms = [Date]()
    var carbonWithinIntervalIntervals = [TimeInterval]()
    var updateScoreArgs: [MeasuredActivity] = []

    func carbonWithinInterval(motionType: MeasuredActivity.MotionType, from: Date, interval: TimeInterval) throws -> Double {
        carbonWithinIntervalMotionTypes.append(motionType)
        carbonWithinIntervalFroms.append(from)
        carbonWithinIntervalIntervals.append(interval)
        return 0
    }
    
    func updateScore(activity: MeasuredActivity) throws {
        updateScoreArgs.append(activity)
    }
    
    func carbonFromPollutingMotions(from: Date, interval: TimeInterval) throws -> Double {return 0}
    func setActivityWrittenCallback(callback: @escaping (MeasuredActivity) -> Void) {}
    func distanceWithinInterval(motionType: MeasuredActivity.MotionType, from: Date, interval: TimeInterval) throws -> Double {return 0}
    func distanceWithinIntervalAll(from: Date, interval: TimeInterval) throws -> Double {return 0}
    func updateLeague(newLeague: String) throws {}
    func retrieveLatestScore() throws -> Double { 0 }
    func updateLeagueIfEnoughPoints() throws {}
    func getFirstDate() throws -> Date {return Date(timeIntervalSince1970: 0)}
    func queryActivities(predicate: String?, args: [Any]?) throws -> [MeasuredActivity] {return []}
    func executeQuery(entity: String, predicate: String?, args: [Any]?) throws -> [Any] {return []}
    func getFirstDate() throws -> Date? { return nil}
    func getForestItems() throws -> [ForestItem] { return [] }
    func saveForestItem(_ item: ForestItem) throws {}
    func addFoodsWrittenCallback(callback: @escaping ([Food]) -> Void) {}
    func queryFoods(predicate: String?, args: [Any]?) throws -> [Food] { return [] }
    func addActivityWrittenCallback(callback: @escaping (MeasuredActivity) -> Void) {}
}
