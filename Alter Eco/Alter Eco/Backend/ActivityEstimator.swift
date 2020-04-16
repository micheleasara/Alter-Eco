import Foundation
import CoreLocation
import MapKit

/**
 The activity estimator's responsibility is to elaborate location information to infer what kind of activity (e.g. transportation) the user is doing and to then save it in the database.
 
 Activities are computed on the basis of location updates. A location update must be far enough in both time and space as specified by the relative constants.
 Activities can be speed-based (e.g. car or walking) if they are computed on the basis of the speed estimated by the location updates.
 Alternatively, an activity is said to be region-of-interest (ROI) based if its estimation depends on whether the user has visited specific locations (e.g. airports).
 */
public class ActivityEstimator<T:ActivityList> {
    /// Nearby train/underground stations. Used to determine train activities.
    public var stations: [MKMapItem] = []
    /// Nearby airports. Used to determine flight activities.
    public var airports: [MKMapItem] = []
    
    /// Contains location information of visit to tube station, nil if not recently in a tube station
    private var previousStation: CLLocation? = nil
    /// Contains location information of visit to airport, nil if not recently in an airport
    private var previousAirport: CLLocation? = nil
    /// Contains location from previous valid update
    private var previousLoc: CLLocation? = nil
    /// Manages countdowns to expire flags for ROI-based activities
    private var timers : CountdownHandler!

    /// Container for user activities containing a motion type and timestamps
    private var measurements: T
    /// Defines how many activities' motion types must be different from the previous ones for a new speed-based activity to be computed
    private let numChangeActivity: Int
    
    /**
     Initializes an activity estimator which makes use of the ActivityList provided.
     - Parameter activityList: activity list which will be used to contain activities and to write to a database.
     - Parameter numChangeActivity: how many activities' motion types must be different from the previous ones for a new speed-based activity to be computed.
     - Parameter timer: object to perform delayed actions; used to deactivate ROIs' flags and other time-based actions.
     */
    public init(activityList: T, numChangeActivity: Int, timers: CountdownHandler) {
        self.measurements = activityList
        self.numChangeActivity = numChangeActivity
        self.timers = timers
    }
    
    /// Processes the location provided to estimate an activity. Computation and storage of activities is automatic as long as locations are provided.
    public func processLocation(_ location: CLLocation) {
        if isLocationAccurate(location) && isLocationFarEnough(location) && !isLocationUpdateInstantaneous(location) {
            print("valid location received")
            
            // determine regions of interest
            let currentStation = getCurrentROI(currentLocation: location, regionsOfInterest: self.stations, gpsThreshold: GPS_UPDATE_CONFIDENCE_THRESHOLD)
            let currentAirport = getCurrentROI(currentLocation: location, regionsOfInterest: self.airports, gpsThreshold: GPS_UPDATE_AIRPORT_THRESHOLD)
            
            // append speed-based measurement to list
            addSpeedBasedActivity(location: location)
            
            if visitedRegionOfInterest(currentStation) {
                processCurrentROI(currentStation!, prevROI: &previousStation, motionType: .train, currentLoc: location)
            }
            else if visitedRegionOfInterest(currentAirport) {
                processCurrentROI(currentAirport!, prevROI: &previousAirport, motionType: .plane, currentLoc: location)
            }
            else if visitedRegionOfInterest(previousStation) && !visitedRegionOfInterest(currentStation) {
                checkROIFlagStillValid(activityNumToOff: WALK_NUM_FOR_TRAIN_FLAG_OFF, motionType: .walking, prevROI: &previousStation, currentLoc: location)
            }
            else if visitedRegionOfInterest(previousAirport) && !visitedRegionOfInterest(currentAirport) {
                checkROIFlagStillValid(activityNumToOff: CAR_NUM_FOR_PLANE_FLAG_OFF, motionType: .car, prevROI: &previousAirport, currentLoc: location)
            }
            // not the first location received
            else if previousLoc != nil {
                // check if there has been a significant change in speed-based activities
                processSignificantChanges()
                // start countdown for activity list expiration
                timers.start(key: "expired", interval: ACTIVITY_TIMEOUT, block: activityHasExpired)
            }
        
            previousLoc = location
        }
    }
    
    private func isLocationAccurate(_ location: CLLocation) -> Bool {
        // accuracy here means phyisical error in meters (the smaller the better)
        return location.horizontalAccuracy <= GPS_UPDATE_CONFIDENCE_THRESHOLD
    }
    
    // Ensures update happened after roughly GPS_UPDATE_THRESHOLD meters (within tolerance value)
    private func isLocationFarEnough(_ location: CLLocation) -> Bool {
        guard previousLoc != nil else { return true }
        let distance = location.distance(from: previousLoc!)
        return distance + GPS_UPDATE_DISTANCE_TOLERANCE >= GPS_UPDATE_DISTANCE_THRESHOLD
    }
    
    // Checks if a location update is approximately instantaneous
    private func isLocationUpdateInstantaneous(_ location: CLLocation) -> Bool {
        guard previousLoc != nil else { return false }
        return location.timestamp.timeIntervalSince(previousLoc!.timestamp).rounded() <= 0
    }
    
    private func visitedRegionOfInterest(_ regionOfInterest: CLLocation?) -> Bool {
        return regionOfInterest != nil
    }
    
    private func addSpeedBasedActivity(location: CLLocation) {
        // cannot compute if this is the first location we receive
        if let previousLoc = previousLoc {
            let distance = location.distance(from: previousLoc)
            let time = location.timestamp.timeIntervalSince(previousLoc.timestamp)
            let speed = distance / time
            let motionType = MeasuredActivity.speedToMotionType(speed: speed)
            
            measurements.add(MeasuredActivity(motionType: motionType, distance: distance, start: previousLoc.timestamp, end: location.timestamp))
        }
    }
    
    private func processSignificantChanges() {
        guard measurements.count > 0 else { return }
        // look for indexes of changes in motion type
        var changes : [Int] = []
        for i in stride(from: 0, to: measurements.count - 1, by: 1) {
            if measurements[i].motionType != measurements[i+1].motionType {
                changes.append(i)
            }
        }
        changes.append(measurements.count - 1)
        
        // for each change, check if it is a significant change or noise
        var activityStart = 0
        for j in stride(from: 1, to: changes.count, by: 1) {
            if changes[j] - changes[j-1] >= numChangeActivity {
                measurements.writeToDatabase(from: activityStart, to: changes[j] - 1)
                activityStart = changes[j]
            }
        }
    }
    
    private func activityHasExpired() {
        if previousStation == nil && previousAirport == nil {
            measurements.dumpToDatabase(from: 0, to: measurements.count - 1)
        }
    }
    
    private func getCurrentROI(currentLocation: CLLocation, regionsOfInterest: [MKMapItem], gpsThreshold: Double) -> CLLocation? {
        for regionOfInterest in regionsOfInterest {
            let regionLocation = CLLocation(latitude: regionOfInterest.placemark.coordinate.latitude, longitude: regionOfInterest.placemark.coordinate.longitude)
            if (regionLocation.distance(from: currentLocation) <= gpsThreshold) {
                print("In ROI: \(String(describing: regionOfInterest.name))")
                return regionOfInterest.placemark.location
            }
        }
        return nil
    }
    
    
    private func processCurrentROI(_ currentROI: CLLocation, prevROI: inout CLLocation?, motionType: MeasuredActivity.MotionType, currentLoc: CLLocation) {
        print("processing with previous ROI: ", prevROI?.coordinate ?? "NIL", " and current ROI: ", currentROI.coordinate)
        
        if visitedRegionOfInterest(prevROI) {
            if currentROI.distance(from: prevROI!).rounded() > 0 {
                // different ROIs: a trip has occurred!
                let speed = (motionType == .train) ? AVERAGE_TUBE_SPEED : AVERAGE_PLANE_SPEED
                addROIBasedActivity(currentRegionOfInterest: currentROI, previousRegionOfInterest: &prevROI, speed: speed, motionType: motionType)
                resetROITimer(motionType)
            } else {
                // update timestamp, as the current ROI is the same as before
                prevROI = currentROI
            }
        } else {
            // first time visiting this ROI
            prevROI = currentROI
            resetROITimer(motionType)
        }
    }
    
    private func resetROITimer(_ motionType: MeasuredActivity.MotionType) {
        motionType == .train ? timers.start(key: "station", interval: STATION_TIMEOUT, block: stationTimedOut) : timers.start(key: "airport", interval: AIRPORT_TIMEOUT, block: airportTimedOut)
    }
    
    private func addROIBasedActivity(currentRegionOfInterest: CLLocation, previousRegionOfInterest: inout CLLocation?, speed: Double, motionType: MeasuredActivity.MotionType) {
        guard previousRegionOfInterest != nil else { return }
        let activityDistance = abs(speed * (previousRegionOfInterest!.timestamp.timeIntervalSince(currentRegionOfInterest.timestamp)))
        
        print("Used train/plane to travel distance: ", activityDistance, " m")
        let activity = MeasuredActivity(motionType: motionType, distance: activityDistance, start: previousRegionOfInterest!.timestamp, end: currentRegionOfInterest.timestamp)
        previousRegionOfInterest = currentRegionOfInterest
        measurements.add(activity)
    }
    
    private func checkROIFlagStillValid(activityNumToOff: Int, motionType: MeasuredActivity.MotionType, prevROI: inout CLLocation?, currentLoc: CLLocation) {
        guard previousLoc != nil else { return }
        guard measurements.count >= activityNumToOff else { return }
        
        let newActivityIndex = measurements.count - activityNumToOff
        for i in stride(from: newActivityIndex, to: measurements.count, by: 1) {
            // flag is still valid
            print(motionType)
            if measurements[i].motionType != motionType {
                print(measurements[i].motionType)
                return
            }
        }
        // flag is invalid
        prevROI = nil
        processSignificantChanges()
    }
    
    private func stationTimedOut() {
        self.previousStation = nil
        processSignificantChanges()
        measurements.dumpToDatabase(from: 0, to: measurements.count-1)
    }
    
    private func airportTimedOut() {
        self.previousAirport = nil
        processSignificantChanges()
        measurements.dumpToDatabase(from: 0, to: measurements.count-1)
    }
}
