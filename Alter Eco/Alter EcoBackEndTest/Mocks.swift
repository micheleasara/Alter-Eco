import Foundation
import AVFoundation
import UIKit
import AlterEcoBackend

// MARK: Xcode does not offer any mocking package as of now (05/2020), so mocks are created manually

class RemoteFoodUploaderMock: RemoteFoodUploader {
    public var uploadArgs: [(food: Food, completionHandler: (Data?, URLResponse?, Error?) -> Void)] = []
    func upload(food: Food, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        uploadArgs.append((food, completionHandler))
    }
}

class FoodToCarbonConverterMock: FoodToCarbonConverter {
    public var getCarbonArrayArgs: [[Food]] = []
    func getCarbon(fromFoods foods: [Food]) -> Measurement<UnitMass> {
        getCarbonArrayArgs.append(foods)
        return Measurement(value: 0, unit: .kilograms)
    }
    
    public var getCarbonArgs: [Food] = []
    func getCarbon(fromFood food: Food) -> Measurement<UnitMass>? {
        getCarbonArgs.append(food)
        return Measurement(value: 0, unit: .kilograms)
    }
}


class RemoteFoodRetrieverMock: RemoteFoodRetriever {
    public var fetchFoodArgs: [(barcode: String, completionHandler: (Food?, RemoteFoodRetrievalError?) -> Void)] = []
    func fetchFood(barcode: String,
                   completionHandler: @escaping (Food?, RemoteFoodRetrievalError?) -> Void) {
        fetchFoodArgs.append((barcode, completionHandler))
    }
}

class ScannerDelegateMock: UIViewController, ScannerDelegate {
    public var setCodesRetrievalCallbackArgs: [(Set<String>) -> Void] = []
    func setCodesRetrievalCallback(_ callback: @escaping (Set<String>) -> Void) {
        setCodesRetrievalCallbackArgs.append(callback)
    }
    
    public var displayWaitingSpinnerCallCount = 0
    func displayWaitingSpinner() {
        displayWaitingSpinnerCallCount += 1
    }
    
    public var onRuntimeAVErrorArgs: [AVError] = []
    func onRuntimeAVError(error: AVError) {
        onRuntimeAVErrorArgs.append(error)
    }
    
    public var displayErrorAndDismissArgs: [String] = []
    func displayErrorAndDismiss(withMessage message: String) {
        displayErrorAndDismissArgs.append(message)
    }
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DBWriterMock: DBWriter {
    func delete(entity: String, predicate: String?, args: [Any]?) throws {
    }
    
    func addNewPollutingItemCallback(callback: @escaping (PollutingItemType) -> Void) {
    }
    
    func updateScore(toValue value: Double) throws {
    }
    
    var appendFoodsArgs: [(foods: [Food], withDate: Date)] = []
    func append(foods: [Food], withDate: Date) throws {
        appendFoodsArgs.append((foods, withDate))
    }
    
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
    func saveForestItem(_ item: ForestItem) throws {}
    
    var getFirstDateCalls: Int = 0
    func getFirstDate() throws -> Date? {
        getFirstDateCalls += 1
        return Date(timeIntervalSince1970: 0)
    }
    
    var carbonWithinIntervalTotalArgs: [(from: Date, addingInterval: Double)] = []
    func carbonWithinInterval(from date: Date, addingInterval interval: Double) throws -> Measurement<UnitMass> {
        carbonWithinIntervalTotalArgs.append((date, interval))
        return Measurement(value: 0, unit: .kilograms)
    }
    
    var carbonFromFoodsArgs: [(predicate: String?, args: [Any]?)] = []
    func carbonFromFoods(predicate: String?, args: [Any]?) throws -> Measurement<UnitMass> {
        carbonFromFoodsArgs.append((predicate, args))
        return Measurement(value: 0, unit: .kilograms)
    }
    
    var carbonWithinIntervalMotionTypes = [MeasuredActivity.MotionType]()
    var carbonWithinIntervalFroms = [Date]()
    var carbonWithinIntervalIntervals = [TimeInterval]()

    func carbonWithinInterval(motionType: MeasuredActivity.MotionType, from: Date, interval: TimeInterval) throws -> Double {
        carbonWithinIntervalMotionTypes.append(motionType)
        carbonWithinIntervalFroms.append(from)
        carbonWithinIntervalIntervals.append(interval)
        return 0
    }
    
    var updateScoreArgs: [MeasuredActivity] = []
    func updateScore(activity: MeasuredActivity) throws {
        updateScoreArgs.append(activity)
    }
    
    var retrieveLatestScoreCalls = 0
    func retrieveLatestScore() throws -> Double {
        retrieveLatestScoreCalls += 1
        return 0
    }

    
    func carbonFromPollutingMotions(from: Date, interval: TimeInterval) throws -> Double {return 0}
    func distanceWithinInterval(motionType: MeasuredActivity.MotionType, from: Date, interval: TimeInterval) throws -> Double {return 0}
    func distanceWithinIntervalAll(from: Date, interval: TimeInterval) throws -> Double {return 0}
    func queryActivities(predicate: String?, args: [Any]?) throws -> [MeasuredActivity] {return []}
    func executeQuery(entity: String, predicate: String?, args: [Any]?) throws -> [Any] {return []}
    func getForestItems() throws -> [ForestItem] { return [] }
    func queryFoods(predicate: String?, args: [Any]?) throws -> [Food] { return [] }
}
