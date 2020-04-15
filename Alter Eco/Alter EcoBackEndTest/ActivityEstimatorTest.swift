import XCTest
import CoreLocation
import MapKit
@testable import AlterEcoBackend

class ActivityEstimatorTest: XCTestCase {
    var list : ActivityListMock!
    var estimator : ActivityEstimator<ActivityListMock>!
    
    override func setUp() {
        super.setUp()
        list = ActivityListMock()
        estimator = ActivityEstimator<ActivityListMock>(activityList: list, inStationRadius: GPS_UPDATE_DISTANCE_THRESHOLD, stationTimeout: STATION_TIMEOUT, airportTimeout: AIRPORT_TIMEOUT, numChangeActivity: CHANGE_ACTIVITY_THRESHOLD)
    }

    func testValidMovementIsAppendedToMeasurements() {
        let accuracy = GPS_UPDATE_CONFIDENCE_THRESHOLD
        let previousLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date())

        let currentLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4954, longitude: -0.17863), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 20, since: previousLocation.timestamp))

        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)

        XCTAssert(list.addCalls == 1, "Expected one call for add, but got " + String(list.addCalls))
    }

    func testInaccurateActivityIsNotAppendedToMeasurements() {
        // ensure activity is not accurate
        let accuracy = GPS_UPDATE_CONFIDENCE_THRESHOLD + GPS_UPDATE_DISTANCE_TOLERANCE + 1
        
        let previousLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let currentLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4954, longitude: -0.17863), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 20, since: previousLocation.timestamp))

        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)

        XCTAssert(list.addCalls == 0, "Expected no calls for add, but got \(list.addCalls)")
    }
    
    func testInstantaneousLocationUpdatesAreNotConsidered() {
        let accuracy = GPS_UPDATE_CONFIDENCE_THRESHOLD
        
        // 0s between updates
        let previousLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let currentLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4954, longitude: -0.17863), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: previousLocation.timestamp)

        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)

        XCTAssert(list.addCalls == 0, "Expected no calls for add, but got \(list.addCalls)")
    }

    func testLocationUpdatesAreNotConsideredIfTooCloseInSpace() {
        let accuracy = GPS_UPDATE_CONFIDENCE_THRESHOLD
        
        // 0m between updates
        let previousLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let currentLocation = CLLocation(coordinate: previousLocation.coordinate, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: previousLocation.timestamp.addingTimeInterval(100))

        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)

        XCTAssert(list.addCalls == 0, "Expected no calls for add, but got \(list.addCalls)")
    }
    
    func testGoingFromAStationToAnotherAddsTrain() {
        let accuracy = GPS_UPDATE_CONFIDENCE_THRESHOLD
        let coordStationA = CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439)
        let coordStationB = CLLocationCoordinate2D(latitude: 30, longitude: 30)

        let previousLocation = CLLocation(coordinate: coordStationA, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let currentLocation = CLLocation(coordinate: coordStationB, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 1000, since: previousLocation.timestamp))
        // set stations to given coordinates and simulate location updates
        estimator.stations = [MKMapItem(placemark: MKPlacemark(coordinate: coordStationA)), MKMapItem(placemark: MKPlacemark(coordinate: coordStationB))]
        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)

        XCTAssert(list.addCalls == 1, "Expected one call for add, but got \(list.addCalls)")
        XCTAssert(list.measurements[0].motionType == .train, "Expected train, but got \(list.measurements[0].motionType)")
    }
    
    func testGoingFromAnAirportToAnotherAddsPlane() {
        let accuracy = GPS_UPDATE_CONFIDENCE_THRESHOLD
        let coordStationA = CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439)
        let coordStationB = CLLocationCoordinate2D(latitude: 30, longitude: 30)

        let previousLocation = CLLocation(coordinate: coordStationA, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let currentLocation = CLLocation(coordinate: coordStationB, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 1000, since: previousLocation.timestamp))
        // set stations to given coordinates and simulate location updates
        estimator.airports = [MKMapItem(placemark: MKPlacemark(coordinate: coordStationA)), MKMapItem(placemark: MKPlacemark(coordinate: coordStationB))]
        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)

        XCTAssert(list.addCalls == 1, "Expected one call for add, but got \(list.addCalls)")
        XCTAssert(list.measurements[0].motionType == .plane, "Expected plane, but got \(list.measurements[0].motionType)")
    }
    
    func testEstimatorDumpsToDatabaseIfActivityChangesSignificantly() {
        var date = Date(timeIntervalSince1970: 0)
        let accuracy = GPS_UPDATE_CONFIDENCE_THRESHOLD
        
        for _ in 1...CHANGE_ACTIVITY_THRESHOLD {
            list.add(MeasuredActivity(motionType: .car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        }
        XCTAssert(list.count == CHANGE_ACTIVITY_THRESHOLD)
        for _ in 1...CHANGE_ACTIVITY_THRESHOLD {
            list.add(MeasuredActivity(motionType: .walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
        }
        
        // simulate extra walking
        let previousLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let currentLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4954, longitude: -0.17863), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 99999999, since: previousLocation.timestamp))
        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)
        
        let numElements = 2*CHANGE_ACTIVITY_THRESHOLD + 1
        XCTAssert(list.addCalls == numElements, "Expected \(numElements), but got \(list.addCalls)")
        XCTAssert(list.dumpToDatabaseCalls == 1, "Expected one call, but got \(list.dumpToDatabaseCalls)")
        XCTAssert(list.dumpToDatabaseArguments[0] == 0 && list.dumpToDatabaseArguments[1] == numElements - CHANGE_ACTIVITY_THRESHOLD - 1, "Arguments where \(list.dumpToDatabaseArguments)")
        
    }
    
    class ActivityListMock : ActivityList {
        public var measurements : [MeasuredActivity] = []
        public typealias Index = Array<MeasuredActivity>.Index
        public typealias Element = Array<MeasuredActivity>.Element
        public typealias Iterator = Array<MeasuredActivity>.Iterator
        public var startIndex: Index { return measurements.startIndex }
        public var endIndex: Index { return measurements.endIndex }
        
        public var addCalls : Int = 0
        public var removeCalls : Int = 0
        public var removeAllCalls : Int = 0
        public var dumpToDatabaseCalls : Int = 0
        public var dumpToDatabaseArguments : [Int] = []
        
        func add(_ activity:MeasuredActivity) {
            measurements.append(activity)
            addCalls += 1
        }
        func remove(at:Index) {
            removeCalls += 1
        }
        func removeAll() {
            removeAllCalls += 1
        }
        func dumpToDatabase(from:Int, to:Int) {
            dumpToDatabaseCalls += 1
            dumpToDatabaseArguments.append(from)
            dumpToDatabaseArguments.append(to)
        }
        
        func hasChangedSignificantly() -> Bool {
            if measurements.count <= CHANGE_ACTIVITY_THRESHOLD { return false }
            
            let rootType = measurements[0].motionType
            var previousLastType: MeasuredActivity.MotionType? = nil
            for index in stride(from: (measurements.count-CHANGE_ACTIVITY_THRESHOLD-1), to: measurements.count, by: 1) {
                let type = measurements[index].motionType
                if type == rootType || (previousLastType != nil && previousLastType != type) {
                    return false
                }
                previousLastType = type
            }
            
            return true
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
}
