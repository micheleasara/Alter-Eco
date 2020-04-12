import Foundation
import CoreLocation
import MapKit

public class ActivityEstimator : ObservableObject {
    // nearby stations
    public var stations: [MKMapItem] = []
    // nearby airports
    public var airports: [MKMapItem] = []
    // contains location information of visit to tube station, nil if not recently in a tube station
    private var previousStation: CLLocation? = nil
    // contains location information of visit to airport, nil if not recently in an airport
    private var previousAirport: CLLocation? = nil
    // contains location from previous valid update
    private var previousLoc: CLLocation? = nil
    // executes countdown for the validity of the train station flag
    private var stationValidityTimer = Timer()
    // executes countdown for the validity of the plane flag
    private var airportValidityTimer = Timer()
    // seconds after which all train station flags are reset
    private let stationTimeout:Double
    // seconds after which all plane flags are reset
    private let airportTimeout:Double
    // define how many measurements in a row must be different from the root before an activity is averaged
    private let numChangeActivity: Int
    // define how close one has to be to be considered within a station
    private let inStationRadius:Double
    private let activityWeights: [MeasuredActivity.MotionType: Int] = [.car: 2, .walking: 1]
    // container for user activities containing a motion type and timestamps
    private var measurements: WeigthedActivityList
        
    public init(numChangeActivity:Int, inStationRadius:Double, stationTimeout:Double, airportTimeout:Double, DBMS:CoreDataManager) {
        self.stationTimeout = stationTimeout
        self.airportTimeout = airportTimeout
        self.numChangeActivity = numChangeActivity
        self.inStationRadius = inStationRadius
        self.measurements = WeigthedActivityList(activityWeights: activityWeights, numChangeActivity: numChangeActivity, DBMS: DBMS)
    }
    
    public func processLocation(_ location: CLLocation) {
        print("received a location")
        // ensure this is not the first location we are receiving
        if let previousLocation = previousLoc {
            let measurement = MeasuredActivity.getValidMeasuredActivity(location: location, previousLocation: previousLocation, previousAirport: previousAirport)
            guard let validMeasurement = measurement else {return}
            
            let currentStation = getCurrentRegionOfInterest(currentLocation: location, regionsOfInterest: self.stations, GPS_THRESHOLD: GPS_UPDATE_CONFIDENCE_THRESHOLD, trackingDataAttribute: 0)
            let currentAirport = getCurrentRegionOfInterest(currentLocation: location, regionsOfInterest: self.airports, GPS_THRESHOLD: GPS_UPDATE_AIRPORT_THRESHOLD, trackingDataAttribute: 1)
                                    
            // check if we are not in the same day to break the list, with the exception of the train flag and plane flag
            if previousAirport == nil && previousStation == nil && !inSameDay(date1: previousLocation.timestamp, date2: location.timestamp)  {
                measurements.dumpToDatabase(from: 0, to: measurements.count)
            } else {
                measurements.add(validMeasurement)
                
                // check if we are currently in a train station
                if currentStation != nil {
                    processCurrentRegionOfInterest(currentStation!, previousRegionOfInterest: &previousStation, speed: AVERAGE_TUBE_SPEED, motionType: .train)
                }
                
                // check if we are currently in an airport
                else if currentAirport != nil {
                    processCurrentRegionOfInterest(currentAirport!, previousRegionOfInterest: &previousStation, speed: AVERAGE_PLANE_SPEED, motionType: .plane)
                }
                    
                // not in station and were before, if more than set number of walking measurements, forget flag
                else if currentStation == nil && previousStation != nil && measurements.count > numChangeActivity {
                    checkROIFlagStillValid(numChangeActivity: numChangeActivity, activityNumToOff: WALK_NUM_FOR_TRAIN_FLAG_OFF, motionType: .walking, previousRegionOfInterest: &previousStation)
                }
                
                // not in airport and were before, if more than set number of car measurements, forget flag
                else if currentAirport == nil && previousAirport != nil && measurements.count > numChangeActivity * CAR_NUM_FOR_PLANE_FLAG_OFF {
                    checkROIFlagStillValid(numChangeActivity: numChangeActivity, activityNumToOff: CAR_NUM_FOR_PLANE_FLAG_OFF, motionType: .car, previousRegionOfInterest: &previousAirport)
                }
            }
        }
        previousLoc = location
    }
                    
    private func getCurrentRegionOfInterest(currentLocation: CLLocation, regionsOfInterest: [MKMapItem], GPS_THRESHOLD: Double, trackingDataAttribute: Int) -> CLLocation? {
        for regionOfInterest in regionsOfInterest {
            let regionLocation = CLLocation(latitude: regionOfInterest.placemark.coordinate.latitude, longitude: regionOfInterest.placemark.coordinate.longitude)
            if (regionLocation.distance(from: currentLocation) <= GPS_THRESHOLD) {
                return regionOfInterest.placemark.location
            }
        }
        return nil
    }
    
    private func processCurrentRegionOfInterest(_ currentRegionOfInterest: CLLocation, previousRegionOfInterest: inout CLLocation?, speed: Double, motionType: MeasuredActivity.MotionType){
        
        // check if there was a journey (plane or train)
        if previousRegionOfInterest != nil && currentRegionOfInterest.distance(from: previousRegionOfInterest!).rounded() > 0 {
            computeActivityFromROIs(currentRegionOfInterest: currentRegionOfInterest, previousRegionOfInterest: &previousRegionOfInterest, speed: speed, motionType: motionType)
            motionType == .train ? resetTimer(timer: &stationValidityTimer, timeOut: stationTimedOut) : resetTimer(timer: &airportValidityTimer, timeOut: airportTimedOut)
        }
            
        // while in same airport/tube station, update timestamp
        else if previousRegionOfInterest != nil && currentRegionOfInterest.distance(from: previousRegionOfInterest!).rounded() <= 0 {
            
            previousRegionOfInterest = CLLocation(coordinate: previousRegionOfInterest!.coordinate, altitude: previousRegionOfInterest!.altitude, horizontalAccuracy: previousRegionOfInterest!.horizontalAccuracy, verticalAccuracy: previousRegionOfInterest!.verticalAccuracy, course: previousRegionOfInterest!.course, speed: previousRegionOfInterest!.speed, timestamp: Date())
        }
            
        // In regionOfInterest right now and weren't before
        else if previousRegionOfInterest == nil {
            previousRegionOfInterest = currentRegionOfInterest
            motionType == .train ? resetTimer(timer: &stationValidityTimer, timeOut: stationTimedOut) : resetTimer(timer: &airportValidityTimer, timeOut: airportTimedOut)
        }
    }
    
    private func computeActivityFromROIs(currentRegionOfInterest: CLLocation, previousRegionOfInterest: inout CLLocation?, speed: Double, motionType: MeasuredActivity.MotionType){
        let activityDistance = abs(speed * (previousRegionOfInterest!.timestamp.timeIntervalSince(currentRegionOfInterest.timestamp)))
        
        print("Used train to travel distance: ", activityDistance, " m")
        let activity = MeasuredActivity(motionType: motionType, distance: activityDistance, start: previousRegionOfInterest!.timestamp, end: currentRegionOfInterest.timestamp)
        previousRegionOfInterest = currentRegionOfInterest
        measurements.add(activity)
    }
    
    private func resetTimer(timer: inout Timer, timeOut: (Timer) -> Void){
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: stationTimeout, target: self, selector: #selector(stationTimedOut(timer:)), userInfo: nil, repeats: false)
    }
    
    private func resetAirportTimer(){
        airportValidityTimer.invalidate()
        airportValidityTimer = Timer.scheduledTimer(timeInterval: airportTimeout, target: self, selector: #selector(airportTimedOut(timer:)), userInfo: nil, repeats: false)
    }
    
    private func dumpOldDay() {
        for i in 1...measurements.count - 1 {
            if !inSameDay(date1: measurements[i].start, date2: measurements[0].start) {
                measurements.dumpToDatabase(from: 0, to: i-1)
            }
        }
    }
    
    @objc private func stationTimedOut(timer: Timer) {
        self.previousStation = nil
        dumpOldDay()
    }
    
    @objc private func airportTimedOut(timer: Timer) {
        self.previousAirport = nil
        dumpOldDay()
    }
    
    private func checkROIFlagStillValid(numChangeActivity: Int, activityNumToOff: Int, motionType: MeasuredActivity.MotionType, previousRegionOfInterest: inout CLLocation?){
        let newActivityIndex = measurements.count - activityNumToOff

        for i in 0..<newActivityIndex {
            if measurements[i].motionType != motionType {
                return
            }
        }
        
        previousRegionOfInterest = nil
        measurements.dumpToDatabase(from: 0, to: newActivityIndex - 1)
    }
    
    private func inSameDay(date1:Date, date2:Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.dateComponents([.day, .month, .year], from: date1) == calendar.dateComponents([.day, .month, .year], from: date2)
    }
}
