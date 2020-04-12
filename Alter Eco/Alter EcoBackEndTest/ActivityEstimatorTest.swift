//import XCTest
//import CoreLocation
//@testable import Alter_Eco
//
//class ActivityEstimatorTest: XCTestCase {
//
//    let estimator = ActivityEstimator(numChangeActivity: CHANGE_ACTIVITY_THRESHOLD, maxMeasurements: MAX_MEASUREMENTS, inStationRadius: GPS_UPDATE_CONFIDENCE_THRESHOLD, stationTimeout: STATION_TIMEOUT, airportTimeout: AIRPORT_TIMEOUT)
//
//    func testValidMovementIsAppendedToMeasurementsList() {
//        let accuracy = GPS_UPDATE_CONFIDENCE_THRESHOLD
//        let previousLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date())
//
//        let currentLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4954, longitude: -0.17863), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 20, since: previousLocation.timestamp))
//
//        estimator.processLocation(previousLocation)
//        estimator.processLocation(currentLocation)
//
//        XCTAssert(estimator.measurements.count == 1, "Expected one item in the measurements list, but got " + String(estimator.measurements.count))
//    }
//
//    func testRootCarChangesAfterSufficientWalkingMeasurements() {
//        var measurements = [MeasuredActivity]()
//        var date = Date()
//
//        // adding 5 car activities
//        for _ in 1...5 {
//            measurements.append(MeasuredActivity(motionType: .car, distance: 50, start: date, end: Date(timeInterval: 10, since: date)))
//            date = Date(timeInterval: 10, since: date)
//        }
//
//        // adding sufficient walking measurements
//        for _ in 1..<CHANGE_ACTIVITY_THRESHOLD {
//            measurements.append(MeasuredActivity(motionType: .walking, distance: 50, start: date, end: Date(timeInterval: 10, since: date)))
//            date = Date(timeInterval: 10, since: date)
//        }
//        estimator.measurements = measurements
//
//        // fake previous location
//        let oldLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49389, longitude: -0.20447),
//                                       altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date)
//        estimator.processLocation(oldLoc)
//
//        // generate very close new location with a big time difference (i.e. simulate walking)
//        let newLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49187, longitude: -0.20209),
//                                altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date(timeInterval: 5000, since: date) )
//        // simulate location update
//        estimator.processLocation(newLoc)
//
//        // algorithm should create this
//        let finalActivity = MeasuredActivity(motionType: .walking,
//                                             distance: newLoc.distance(from: oldLoc).rounded(),
//                                             start: oldLoc.timestamp, end: newLoc.timestamp)
//        measurements.append(finalActivity)
//        let averageActivity = MeasuredActivity.getAverageActivity(measurements: Array(measurements[..<(measurements.count-CHANGE_ACTIVITY_THRESHOLD)]))
//
//        // retrieve whatever was put in the database
//        let activityRetrieved = executeQuery(query: NSPredicate(format: "end == %@", measurements[measurements.count - CHANGE_ACTIVITY_THRESHOLD - 1].end as NSDate))[0]
//        XCTAssert(averageActivity == activityRetrieved, "Event retrieved does not match what was expected")
//    }
//
//    func testRootWalkChangesAfterSufficientCarMeasurements() {
//        var measurements = [MeasuredActivity]()
//        var date = Date()
//
//        // adding 5 walking events
//        for _ in 1...5 {
//            measurements.append(MeasuredActivity(motionType: .walking, distance: 50, start: date, end: Date(timeInterval: 10, since: date)))
//            date = Date(timeInterval: 10, since: date)
//        }
//
//        // adding one car
//        measurements.append(MeasuredActivity(motionType: .car, distance: 50, start: date, end: Date(timeInterval: 10, since: date)))
//        date = Date(timeInterval: 10, since: date)
//        estimator.measurements = measurements
//
//        // fake previous location
//        let oldLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49389, longitude: -0.20447),
//                                       altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date)
//        estimator.processLocation(oldLoc)
//
//        // generate very close new location with a big time difference (i.e. simulate car)
//        let newLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49187, longitude: -0.20209),
//                                altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date(timeInterval: 3, since: date) )
//
//
//        // simulate location update
//        estimator.processLocation(newLoc)
//
//        // algorithm should create this
//        let finalActivity = MeasuredActivity(motionType: .car,
//                                             distance: newLoc.distance(from: oldLoc).rounded(),
//                                             start: oldLoc.timestamp, end: newLoc.timestamp)
//        measurements.append(finalActivity)
//        let averageActivity = MeasuredActivity.getAverageActivity(measurements: Array(measurements[..<(measurements.count-CHANGE_ACTIVITY_THRESHOLD)]))
//
//        // retrieve whatever was put in the database
//        let activityRetrieved = executeQuery(query: NSPredicate(format: "end == %@", measurements[measurements.count - CHANGE_ACTIVITY_THRESHOLD - 1].end as NSDate))[0]
//        XCTAssert(averageActivity == activityRetrieved, "Activity retrieved does not match what was expected")
//        XCTAssert(finalActivity == estimator.measurements.last!, "Last element in scene measurements is not correct")
//    }
//
//    func testNewDayTriggersNewActivity() {
//        var measurements = [MeasuredActivity]()
//        var date = Date(timeIntervalSince1970: 0)
//
//        // adding 5 walking activities
//        for _ in 1...5 {
//            measurements.append(MeasuredActivity(motionType: .walking, distance: 50, start: date, end: Date(timeInterval: 10, since: date)))
//            date = measurements.last!.end
//        }
//
//        estimator.measurements = measurements
//
//        // previous location added
//        let oldLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49389, longitude: -0.20447),
//                                       altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date)
//        // location in a new day
//        let newLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49187, longitude: -0.20209),
//                                       altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date(timeInterval: 60*60*24, since: date))
//
//        estimator.processLocation(oldLoc)
//        estimator.processLocation(newLoc)
//
//        let finalActivity = MeasuredActivity(motionType: .car,
//                                             distance: newLoc.distance(from: oldLoc).rounded(),
//                                             start: oldLoc.timestamp, end: newLoc.timestamp)
//        measurements.append(finalActivity)
//
//        let averageActivity = MeasuredActivity.getAverageActivity(measurements: Array(measurements[..<(measurements.count-1)]))
//
//        // retrieve whatever was put in the database
//        let activityRetrieved = executeQuery(query: NSPredicate(format: "end == %@", averageActivity.end as NSDate))[0]
//
//        XCTAssert(averageActivity == activityRetrieved, "Activity retrieved does not match what was expected")
//
//        XCTAssert(estimator.measurements.count == 0, "On a new day, measurements should be empty")
//
//    }
//
//    func testFullListTriggersNewActivity() {
//        var measurements = [MeasuredActivity]()
//        var date = Date(timeIntervalSince1970: 0)
//
//        for _ in 1...MAX_MEASUREMENTS-1 {
//            measurements.append(MeasuredActivity(motionType: .walking, distance: 50, start: date, end: Date(timeInterval: 10, since: date)))
//            date = measurements.last!.end
//        }
//
//        estimator.measurements = measurements
//
//        // previous location added
//        let oldLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49389, longitude: -0.20447),
//                                       altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date)
//        // location in a new day
//        let newLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49187, longitude: -0.20209),
//                                       altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date(timeInterval: 5, since: date))
//
//        estimator.processLocation(oldLoc)
//        estimator.processLocation(newLoc)
//
//        let finalActivity = MeasuredActivity(motionType: .car,
//                                             distance: newLoc.distance(from: oldLoc).rounded(),
//                                             start: oldLoc.timestamp, end: newLoc.timestamp)
//
//        measurements.append(finalActivity)
//
//        let averageActivity = MeasuredActivity.getAverageActivity(measurements: measurements)
//
//        // retrieve whatever was put in the database
//        let activityRetrieved = executeQuery(query: NSPredicate(format: "end == %@", averageActivity.end as NSDate))[0]
//        XCTAssert(averageActivity == activityRetrieved, "Activity retrieved does not match what was expected")
//        XCTAssert(estimator.measurements.count == 0, "In new measurements list, measurements should be empty")
//
//    }
//
//}
