import XCTest
import CoreLocation
import MapKit
@testable import AlterEcoBackend

class AppDelegateTest: XCTestCase {

    let app = AppDelegate()
    
    func testRequestNewStationsIfHasntBeenDoneBefore() {
        XCTAssert(app.locationLastStationRequest == nil)
        let date = Date(timeIntervalSince1970: 0)
        let oldLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49389, longitude: -0.20447),
                                       altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date)
        let newLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49187, longitude: -0.20209),
                                       altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date(timeInterval: 5, since: date))

        app.activityEstimator.processLocation(oldLoc)
        app.locationManager(app.manager, didUpdateLocations: [newLoc])

        XCTAssert(app.locationLastStationRequest != nil, "Stations have not been updated.")
    }

    func testRequestNewStationsWhenNewLocationIsFarEnough() {
        let date = Date(timeIntervalSince1970: 0)
        let oldLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49389, longitude: -0.20447),
                                       altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date)
        let newLoc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.49187, longitude: -0.20209),
                                       altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date(timeInterval: 5, since: date))

        app.locationLastStationRequest = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14.49187, longitude: -0.20000),
        altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date(timeInterval: 5, since: date))
        app.activityEstimator.processLocation(oldLoc)
        app.locationManager(app.manager, didUpdateLocations: [newLoc])

        XCTAssert(app.locationLastStationRequest == newLoc, "Stations have not been updated.")
    }
}
