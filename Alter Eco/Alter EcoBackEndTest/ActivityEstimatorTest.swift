import XCTest
import CoreLocation
import MapKit
@testable import AlterEcoBackend

class ActivityEstimatorTest: XCTestCase {
    var list : ActivityListMock!
    var estimator : ActivityEstimator<ActivityListMock>!
    var timers : MultiTimerMock!
    var DBMS: DBWriterMock!
    
    override func setUp() {
        super.setUp()
        list = ActivityListMock()
        timers = MultiTimerMock()
        DBMS = DBWriterMock()
        estimator = ActivityEstimator<ActivityListMock>(activityList: list, numChangeActivity: CHANGE_ACTIVITY_THRESHOLD, timers: timers, DBMS: DBMS)
    }

    func testValidMovementIsAppendedToMeasurements() {
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        let previousLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date())

        let currentLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4954, longitude: -0.17863), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 20, since: previousLocation.timestamp))

        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)

        XCTAssert(list.addCalls == 1, "Expected one call for add, but got " + String(list.addCalls))
    }

    func testInaccurateActivityIsNotAppendedToMeasurements() {
        // ensure activity is not accurate
        let accuracy = GPS_CONFIDENCE_THRESHOLD + GPS_DISTANCE_TOLERANCE + 1
        
        let previousLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let currentLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4954, longitude: -0.17863), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 20, since: previousLocation.timestamp))

        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)

        XCTAssert(list.addCalls == 0, "Expected no calls for add, but got \(list.addCalls)")
    }
    
    func testInstantaneousLocationUpdatesAreNotConsidered() {
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        
        // 0s between updates
        let previousLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let currentLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4954, longitude: -0.17863), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: previousLocation.timestamp)

        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)

        XCTAssert(list.addCalls == 0, "Expected no calls for add, but got \(list.addCalls)")
    }

    func testLocationUpdatesAreNotConsideredIfTooCloseInSpace() {
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        
        // 0m between updates
        let previousLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let currentLocation = CLLocation(coordinate: previousLocation.coordinate, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: previousLocation.timestamp.addingTimeInterval(100))

        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)

        XCTAssert(list.addCalls == 0, "Expected no calls for add, but got \(list.addCalls)")
    }
    
    func testGoingFromAStationToAnotherAddsTrain() {
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        let coordStationA = CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439)
        let coordStationB = CLLocationCoordinate2D(latitude: 30, longitude: 30)

        let previousLocation = CLLocation(coordinate: coordStationA, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let currentLocation = CLLocation(coordinate: coordStationB, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp:
            Date(timeInterval: 999999, since: previousLocation.timestamp))
        // set stations to given coordinates and simulate location updates
        estimator.stations = [MKMapItem(placemark: MKPlacemark(coordinate: coordStationA)), MKMapItem(placemark: MKPlacemark(coordinate: coordStationB))]
        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)

        XCTAssert(DBMS.appendArgs.count == 1, "Got \(DBMS.appendArgs.count)")
        XCTAssert(DBMS.appendArgs[0].motionType == .train,
                  "Expected train, but got \(DBMS.appendArgs[0].motionType)")
    }
    
    func testGoingFromAnAirportToAnotherWritesPlane() {
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        let coordAirportA = CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439)
        let coordAirportB = CLLocationCoordinate2D(latitude: 30, longitude: 30)

        let previousLocation = CLLocation(coordinate: coordAirportA, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let currentLocation = CLLocation(coordinate: coordAirportB, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0,
                                         timestamp: Date(timeInterval: 999999999, since: previousLocation.timestamp))
        // set stations to given coordinates and simulate location updates
        estimator.airports = [MKMapItem(placemark: MKPlacemark(coordinate: coordAirportA)), MKMapItem(placemark: MKPlacemark(coordinate: coordAirportB))]
        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)

        XCTAssert(DBMS.appendArgs.count == 1, "Got \(DBMS.appendArgs.count)")
        XCTAssert(DBMS.appendArgs[0].motionType == .plane,
                  "Expected plane, but got \(DBMS.appendArgs[0].motionType)")
    }
    
    func testEstimatorDumpsToDatabaseIfActivityChangesSignificantly() {
        var date = Date(timeIntervalSince1970: 0)
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        
        for _ in 1...CHANGE_ACTIVITY_THRESHOLD {
            list.add(MeasuredActivity(motionType: .car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        }
        for _ in 1..<NUM_MEASUREMENTS_TO_DETERMINE_ACTIVITY-1 {
            list.add(MeasuredActivity(motionType: .walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
        }
        
        // simulate extra walking
        let previousLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let currentLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.4954, longitude: -0.17863), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 99999999, since: previousLocation.timestamp))
        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)
        
        let numElements = CHANGE_ACTIVITY_THRESHOLD + NUM_MEASUREMENTS_TO_DETERMINE_ACTIVITY - 1
        XCTAssert(list.addCalls == numElements, "Expected \(numElements), but got \(list.addCalls)")
        XCTAssert(DBMS.appendArgs.count == 1, "Expected one call, but got \(DBMS.appendArgs.count)")
    }
    
    func testStationToNonStationByCarIsTreatedAsSpeedBasedActivity() {
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        let station = CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439)
        let nonStation = CLLocationCoordinate2D(latitude: 51.4813213, longitude: -0.1943419)
        var date = Date(timeIntervalSince1970: 0)
        for _ in 1...10 {
            list.add(MeasuredActivity(motionType: .car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 1000, since: date)
        }
        
        let previousLocation = CLLocation(coordinate: station, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let currentLocation = CLLocation(coordinate: nonStation, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 1000, since: previousLocation.timestamp))
        // set stations to given coordinates and simulate location updates
        estimator.stations = [MKMapItem(placemark: MKPlacemark(coordinate: station))]
        estimator.processLocation(previousLocation)
        // simulate car movement
        estimator.processLocation(currentLocation)
        XCTAssert(list.addCalls == 11, "Incorrect number of calls to add. Got \(list.addCalls)")
        XCTAssert(DBMS.appendArgs.count == 0, "Got \(DBMS.appendArgs.count)")
    }
    
    func testAirportToNonAirportByFootIsTreatedAsSpeedBasedActivity() {
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        let airport = CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439)
        // need to go really far away not to be considered within airport
        let nonAirport = CLLocationCoordinate2D(latitude: 48, longitude: -0.1943419)

        var date = Date(timeIntervalSince1970: 0)
        // careful not to trigger flag deactivation
        for _ in 1...10 {
            list.add(MeasuredActivity(motionType: .walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        }
        
        let nonAirportLoc = CLLocation(coordinate: nonAirport, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 9999999999, since: date))
        let airportLoc = CLLocation(coordinate: airport, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: date)
        // set stations to given coordinates and simulate location updates
        estimator.airports = [MKMapItem(placemark: MKPlacemark(coordinate: airport))]
        estimator.processLocation(airportLoc)
        // simulate walking movement
        estimator.processLocation(nonAirportLoc)
        XCTAssert(list.addCalls == 11, "Incorrect number of calls to add. Got \(list.addCalls)")
        XCTAssert(DBMS.appendArgs.count == 0, "Got \(DBMS.appendArgs.count)")
    }
    
    func testAirportFlagIsOffAfterEnoughCars() {
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        let airport = CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439)
        // need to go really far away not to be considered within airport
        let nonAirport = CLLocationCoordinate2D(latitude: 50, longitude: -0.1943419)
        var date = Date(timeIntervalSince1970: 0)
        for _ in 1...CAR_NUM_FOR_PLANE_FLAG_OFF {
            list.add(MeasuredActivity(motionType: .car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 100, since: date)
        }
        
        var airportLoc = CLLocation(coordinate: airport, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        // small time interval to simulate final car event
        let nonAirportLoc = CLLocation(coordinate: nonAirport, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 1000, since: airportLoc.timestamp))
        // set stations to given coordinates and simulate location updates
        estimator.airports = [MKMapItem(placemark: MKPlacemark(coordinate: airport))]
        estimator.processLocation(airportLoc)
        estimator.processLocation(nonAirportLoc)
        // back in airport
        airportLoc = CLLocation(coordinate: airport, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: nonAirportLoc.timestamp.addingTimeInterval(9999))
        estimator.processLocation(airportLoc)
        XCTAssert(list.addCalls == CAR_NUM_FOR_PLANE_FLAG_OFF + 2, "Got \(list.addCalls)")
        XCTAssert(DBMS.appendArgs.count == 0, "Got \(DBMS.appendArgs.count)")
        XCTAssert(list.addArgs[list.addCalls - 1].motionType != .plane)
    }
    
    func testStationFlagIsOffAfterEnoughWalking() {
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        let stationCoord = CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439)
        let nonStationCoord = CLLocationCoordinate2D(latitude: 51.4813213, longitude: -0.1943419)

        var date = Date(timeIntervalSince1970: 0)
        for _ in 1...WALK_NUM_FOR_TRAIN_FLAG_OFF {
            list.add(MeasuredActivity(motionType: .walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        }
        
        var stationLoc = CLLocation(coordinate: stationCoord, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let nonStationLoc = CLLocation(coordinate: nonStationCoord, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 9999999, since: stationLoc.timestamp))
        // set stations to given coordinates and simulate location updates
        estimator.airports = [MKMapItem(placemark: MKPlacemark(coordinate: stationCoord))]
        estimator.processLocation(stationLoc)
        // simulate walk movement
        estimator.processLocation(nonStationLoc)
        // back in airport
        stationLoc = CLLocation(coordinate: stationCoord, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: nonStationLoc.timestamp.addingTimeInterval(9999999))
        estimator.processLocation(stationLoc)
        XCTAssert(list.addCalls == WALK_NUM_FOR_TRAIN_FLAG_OFF + 2, "Incorrect number of calls to add. Got \(list.addCalls)")
        XCTAssert(DBMS.appendArgs.count == 0, "Got \(DBMS.appendArgs.count)")
        XCTAssert(list.addArgs[list.addCalls - 1].motionType != .train)
    }
    
    func testAirportCountdownStartsAfterAirportVisit() {
        XCTAssert(timers.startCalls == 0)
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        let coordAirport = CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439)
        let loc = CLLocation(coordinate: coordAirport, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        estimator.airports = [MKMapItem(placemark: MKPlacemark(coordinate: coordAirport))]
        estimator.processLocation(loc)
        XCTAssert(timers.startCalls == 1)
        XCTAssert(timers.startKeys[0] == "airport")
        XCTAssert(timers.startIntervals[0] == AIRPORT_TIMEOUT)
    }
    
    func testStationCountdownStartsAfterAirportVisit() {
        XCTAssert(timers.startCalls == 0)
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        let coord = CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439)
        let loc = CLLocation(coordinate: coord, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        estimator.stations = [MKMapItem(placemark: MKPlacemark(coordinate: coord))]
        estimator.processLocation(loc)
        XCTAssert(timers.startCalls == 1)
        XCTAssert(timers.startKeys[0] == "station")
        XCTAssert(timers.startIntervals[0] == STATION_TIMEOUT)
    }
    
    func testStationCountdownEndMakesEstimatorProcessSpeedActivitiesChangesAndDumpsLeftovers() {
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        let coord = CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439)
        let loc = CLLocation(coordinate: coord, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        estimator.stations = [MKMapItem(placemark: MKPlacemark(coordinate: coord))]
        estimator.processLocation(loc)
        XCTAssert(timers.startCalls == 1)
        XCTAssert(timers.startKeys[0] == "station")
        XCTAssert(timers.startIntervals[0] == STATION_TIMEOUT)
        
        // add activities which should trigger a change
        var date = Date(timeIntervalSince1970: 0)
        for _ in 1...CHANGE_ACTIVITY_THRESHOLD {
            list.add(MeasuredActivity(motionType: .car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        }
        for _ in 1...CHANGE_ACTIVITY_THRESHOLD {
            list.add(MeasuredActivity(motionType: .walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
        }
        // call end procedure of timer
        timers.startBlocks[0]()
        XCTAssert(DBMS.appendArgs.count == 2, "Got \(DBMS.appendArgs.count)")
        XCTAssert(list.synthesizeArgs == [0, CHANGE_ACTIVITY_THRESHOLD - 1, 0, CHANGE_ACTIVITY_THRESHOLD - 1],
                  "Args of call were \(list.synthesizeArgs)")
        XCTAssert(list.count == 0)
    }
    
    func testAirportCountdownEndMakesEstimatorProcessSpeedActivitiesChangesAndDumpsLeftovers() {
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        let coord = CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439)
        let loc = CLLocation(coordinate: coord, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        estimator.airports = [MKMapItem(placemark: MKPlacemark(coordinate: coord))]
        estimator.processLocation(loc)
        XCTAssert(timers.startCalls == 1)
        XCTAssert(timers.startKeys[0] == "airport")
        XCTAssert(timers.startIntervals[0] == AIRPORT_TIMEOUT)
        
        // add activities which should trigger a change
        var date = Date(timeIntervalSince1970: 0)
        for _ in 1...CHANGE_ACTIVITY_THRESHOLD {
            list.add(MeasuredActivity(motionType: .car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
            date = Date(timeInterval: 10, since: date)
        }
        for _ in 1...CHANGE_ACTIVITY_THRESHOLD {
            list.add(MeasuredActivity(motionType: .walking, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
        }
        // call end procedure of timer
        timers.startBlocks[0]()
        XCTAssert(DBMS.appendArgs.count == 2, "Got \(DBMS.appendArgs.count)")
        XCTAssert(list.synthesizeArgs == [0, CHANGE_ACTIVITY_THRESHOLD - 1, 0, CHANGE_ACTIVITY_THRESHOLD - 1],
                  "Args of call were \(list.synthesizeArgs)")
        XCTAssert(list.count == 0)
    }

    func testActivityWillExpireIfNoROIFlags() {
        let accuracy = GPS_CONFIDENCE_THRESHOLD
        let coord1 = CLLocationCoordinate2D(latitude: 51.4913283, longitude: -0.1943439)
        let coord2 = CLLocationCoordinate2D(latitude: 51.4813213, longitude: -0.1943419)
        
        var date = Date(timeIntervalSince1970: 0)
        list.add(MeasuredActivity(motionType: .car, distance: 100, start: date, end: Date(timeInterval: 10, since: date)))
        date = Date(timeInterval: 10, since: date)

        // trigger location updates
        let previousLocation = CLLocation(coordinate: coord1, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: 0))
        let currentLocation = CLLocation(coordinate: coord2, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: Date(timeInterval: 100, since: previousLocation.timestamp))
        estimator.processLocation(previousLocation)
        estimator.processLocation(currentLocation)
        
        // call end procedure of timer
        XCTAssert(timers.startCalls == 1, "Incorrect number of calls, got \(timers.startCalls)")
        XCTAssert(timers.startKeys[0] == "expired", "Got \(timers.startKeys)")
        XCTAssert(timers.startIntervals[0] == ACTIVITY_TIMEOUT, "Got \(timers.startIntervals)")
        timers.startBlocks[0]()
        XCTAssert(DBMS.appendArgs.count == 1, "Expected one call, but got \(DBMS.appendArgs.count)")
        XCTAssert(list.synthesizeArgs[0] == 0 && list.synthesizeArgs[1] == 1, "Args of call were \(list.synthesizeArgs)")
    }
}
