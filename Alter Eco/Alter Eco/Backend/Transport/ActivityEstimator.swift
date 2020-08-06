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
    /// Represents a set of regions of interest used to compute activities.
    public typealias ROIs = Set<MKMapItem>
    /// Nearby train/underground stations. Used to determine train activities.
    public var stations: ROIs = []
    /// Nearby airports. Used to determine flight activities.
    public var airports: ROIs = []
    
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
    /// Object allowing writing operations to the database.
    private let DBMS: DBWriter
    
    /// Callback function for when the user is thought to be in a station.
    private var inStationCallback: (_ station: CLLocation) -> Void = {_  in }
    /// Callback function for when the user is thought to be in an airport.
    private var inAirportCallback: (_ airport: CLLocation) -> Void = {_  in }
    
    /**
     Initializes an activity estimator which makes use of the ActivityList provided.
     - Parameter activityList: activity list which will be used to contain activities and to write to a database.
     - Parameter numChangeActivity: how many activities' motion types must be different from the previous ones for a new speed-based activity to be computed.
     - Parameter timer: object to perform delayed actions; used to deactivate ROIs' flags and other time-based actions.
     - Parameter DBMS: object allowing writing operations to the database.
     */
    public init(activityList: T, numChangeActivity: Int, timers: CountdownHandler, DBMS: DBWriter) {
        self.measurements = activityList
        self.numChangeActivity = numChangeActivity
        self.timers = timers
        self.DBMS = DBMS
    }
    
    /// Sets a callback which is called when the user is determined to be in a station. The location of the station is passed as a parameter.
    public func setInStationCallback(callback: @escaping (_ station: CLLocation) -> Void) {
        inStationCallback = callback
    }
    
    /// Sets a callback which is called when the user is determined to be in an airport. The location of the airport is passed as a parameter.
    public func setInAirportCallback(callback: @escaping (_ airport: CLLocation) -> Void) {
        inAirportCallback = callback
    }
    
    /// Processes the location provided to estimate an activity. Computation and storage of activities is automatic as long as locations are provided.
    public func processLocation(_ location: CLLocation) {
        if isAccurate(location) && isUpdateSpatiallyValid(location) && !isUpdateInstantaneous(location) {
            print("valid location received")
            // stop countdown for activity list expiration
            timers.stop("expired")
            
            // determine regions of interest, or nil if in none of them
            let currentStation = getCurrentROI(currentLocation: location,
                                               regionsOfInterest: self.stations,
                                               gpsThreshold: STATION_REQUEST_RADIUS)
            let currentAirport = getCurrentROI(currentLocation: location,
                                               regionsOfInterest: self.airports,
                                               gpsThreshold: MAX_AIRPORT_REQUEST_RADIUS)
            
            // append speed-based measurement to list
            addSpeedBasedActivity(location: location)
            
            if visitedRegionOfInterest(currentStation) {
                processCurrentROI(currentStation!, prevROI: &previousStation, motionType: .train)
                inStationCallback(currentStation!)
            }
            else if visitedRegionOfInterest(currentAirport) {
                processCurrentROI(currentAirport!, prevROI: &previousAirport, motionType: .plane)
                inAirportCallback(currentAirport!)
            }
            else if visitedRegionOfInterest(previousStation) && !visitedRegionOfInterest(currentStation) {
                checkROIFlagStillValid(activityNumToOff: WALK_NUM_FOR_TRAIN_FLAG_OFF,
                                       motionType: .walking,
                                       prevROI: &previousStation)
            }
            else if visitedRegionOfInterest(previousAirport) && !visitedRegionOfInterest(currentAirport) {
                checkROIFlagStillValid(activityNumToOff: CAR_NUM_FOR_PLANE_FLAG_OFF,
                                       motionType: .car,
                                       prevROI: &previousAirport)
            }
            // not the first location received
            else if previousLoc != nil {
                processSignificantChanges()
                processMeasurementStreak()
                // start countdown for activity list expiration
                timers.start(key: "expired", interval: ACTIVITY_TIMEOUT, block: activityHasExpired)
            }
        
            previousLoc = location
        }
    }
    
    /// Determines if a location is accurate enough.
    private func isAccurate(_ location: CLLocation) -> Bool {
        // accuracy here means phyisical error in meters (the smaller the better)
        return location.horizontalAccuracy <= GPS_CONFIDENCE_THRESHOLD
    }
    
    /// Ensures update happened after roughly GPS_UPDATE_THRESHOLD meters (within tolerance value) and within a reasonable altitude.
    private func isUpdateSpatiallyValid(_ location: CLLocation) -> Bool {
        guard previousLoc != nil else { return true }
        let distance = location.distance(from: previousLoc!)
        return (distance + GPS_DISTANCE_TOLERANCE) >= GPS_DISTANCE_THRESHOLD && location.altitude <= GPS_MAX_ALTITUDE
    }
    
    /// Checks if a location update is approximately instantaneous.
    private func isUpdateInstantaneous(_ location: CLLocation) -> Bool {
        guard previousLoc != nil else { return false }
        let elapsedTime = location.timestamp.timeIntervalSince(previousLoc!.timestamp)
        return  elapsedTime.rounded(.down) <= 0
    }
    
    /// Returns if the given ROI has been visited recently.
    private func visitedRegionOfInterest(_ regionOfInterest: CLLocation?) -> Bool {
        return regionOfInterest != nil
    }
    
    /// Computes and stores a speed-based activity in the measurements list, unless the activity is invalid (e.g. speed too high).
    private func addSpeedBasedActivity(location: CLLocation) {
        // cannot compute if this is the first location we receive
        if let previousLoc = previousLoc {
            let distance = location.distance(from: previousLoc)
            
            let time = location.timestamp.timeIntervalSince(previousLoc.timestamp)
            let speed = distance / time
            if speed <= MAX_SPEED {
                let motionType = MeasuredActivity.speedToMotionType(speed: speed)
                measurements.add(MeasuredActivity(motionType: motionType,
                                                  distance: distance,
                                                  start: previousLoc.timestamp,
                                                  end: location.timestamp))
            } else {
                print("Speed based activity NOT added as too fast")
            }
        }
    }
    
    /// Looks for significant changes in motion types within the measurements and writes the estimated activity if so.
    private func processSignificantChanges() {
        guard measurements.count > numChangeActivity else { return }
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
        var activityEnd = -1
        print("Before change processing, measurements were:")
        _ = measurements.map { print(MeasuredActivity.motionTypeToString(type: $0.motionType))}
        for j in stride(from: 1, to: changes.count, by: 1) {
            if changes[j] - changes[j-1] >= numChangeActivity {
                activityEnd = changes[j] - numChangeActivity
                writeListToDB(from: activityStart, to: activityEnd)
                print(measurements[activityEnd].end)
                activityStart = changes[j-1] + 1
            }
        }
        // remove activities which have been synthesized
        if activityEnd >= 0 {
            measurements.remove(from: 0, to: activityEnd)
        }
        print("After change processing, measurements were:")
        _ = measurements.map { print(MeasuredActivity.motionTypeToString(type: $0.motionType)) }
    }
    
    /// Writes an activity synthesis to the database if enough measurements of the same kind in a row have happened.
    private func processMeasurementStreak() {
        if !visitedRegionOfInterest(previousAirport) && !visitedRegionOfInterest(previousStation) {
            let start = measurements.count - NUM_MEASUREMENTS_TO_DETERMINE_ACTIVITY
            guard start >= 0 else { return }
            var counter = 0
            for measurement in measurements[start..<measurements.count] {
                if measurement.motionType == measurements[start].motionType {
                    counter += 1
                }
            }
            if counter >= NUM_MEASUREMENTS_TO_DETERMINE_ACTIVITY {
                print("Enough measurements of type ", MeasuredActivity.motionTypeToString(type: measurements[0].motionType), " recorded to determine activity")
                dumpListToDB(from: 0, to: measurements.count - 1)
            }
        }
    }
    
    /// Activity list is not longer valid and it will be dumped to the database.
    private func activityHasExpired() {
        // do not dump if ROI flags are on
        if !visitedRegionOfInterest(previousAirport) && !visitedRegionOfInterest(previousStation) {
            print("speed-based activity has expired, now writing to db...")
            dumpListToDB(from: 0, to: measurements.count - 1)
            previousLoc = nil // start a new session by forgetting the last location
        }
    }
    
    /// Checks if the user is in a ROI within the list provided. Returns the ROI if they are, nil otherwise.
    private func getCurrentROI(currentLocation: CLLocation, regionsOfInterest: ROIs, gpsThreshold: Double) -> CLLocation? {
        for regionOfInterest in regionsOfInterest {
            let regionLocation = CLLocation(latitude: regionOfInterest.placemark.coordinate.latitude, longitude: regionOfInterest.placemark.coordinate.longitude)

            if regionLocation.distance(from: currentLocation) <= gpsThreshold {
                print("In ROI: \(regionOfInterest.name ?? "NIL")")
                return regionOfInterest.placemark.location
            }
        }
        return nil
    }
    
    /// Given the user is in a ROI, checks for a ROI-based activity to have occurred and if so, it saves it. Otherwise, the ROI flag and timer are reset.
    private func processCurrentROI(_ currentROI: CLLocation, prevROI: inout CLLocation?, motionType: MeasuredActivity.MotionType) {
        var averageSpeed: Double = 0
        var minDistance = 0.0
        if motionType == .train {
            averageSpeed = AVERAGE_TUBE_SPEED
            minDistance = MIN_DISTANCE_TRAIN_TRIP
        } else {
            averageSpeed = AVERAGE_PLANE_SPEED
            minDistance = MIN_DISTANCE_FOR_FLIGHT
        }
        
        if visitedRegionOfInterest(prevROI) && currentROI.distance(from: prevROI!) >= minDistance {
            // different ROIs: a trip has occurred!
            addROIBasedActivity(currentRegionOfInterest: currentROI,
                                previousRegionOfInterest: &prevROI,
                                speed: averageSpeed,
                                motionType: motionType)
        } else {
            // first time visiting this ROI or moving inside the same ROI as before
            prevROI = currentROI
        }
        resetROITimer(motionType)
    }
    
    /// Restarts the countdown for the appropriate ROI to expire.
    private func resetROITimer(_ motionType: MeasuredActivity.MotionType) {
        motionType == .train ?
            timers.start(key: "station", interval: STATION_TIMEOUT, block: stationTimedOut) :
            timers.start(key: "airport", interval: AIRPORT_TIMEOUT, block: airportTimedOut)
    }
    
    /// Computes and stores ROI-based activity.
    private func addROIBasedActivity(currentRegionOfInterest: CLLocation, previousRegionOfInterest: inout CLLocation?, speed: Double, motionType: MeasuredActivity.MotionType) {
        guard previousRegionOfInterest != nil else { return }
        let activityDistance = abs(speed * (previousRegionOfInterest!.timestamp.timeIntervalSince(currentRegionOfInterest.timestamp)))
        
        print("Used train/plane to travel distance: ", activityDistance, " m")
        let activity = MeasuredActivity(motionType: motionType, distance: activityDistance, start: previousRegionOfInterest!.timestamp, end: currentRegionOfInterest.timestamp)
        previousRegionOfInterest = currentRegionOfInterest
        writeActivityAndUpdateScore(activity)
        measurements.removeAll()
    }
    
    /// Determines if the ROI flag is invalid due to sufficient subsequent activities of the right kind.
    /// If invalid, flag is deactivated and list is examined for significant changes.
    private func checkROIFlagStillValid(activityNumToOff: Int, motionType: MeasuredActivity.MotionType, prevROI: inout CLLocation?) {
        guard prevROI != nil else { return }
        guard measurements.count >= activityNumToOff else { return }
        
        let newActivityIndex = measurements.count - activityNumToOff
        for i in stride(from: newActivityIndex, to: measurements.count, by: 1) {
            // flag is not valid anymore if there is a streak of specific measurements after ROI flag was set
            if measurements[i].motionType != motionType || measurements[i].start < prevROI!.timestamp {
                return
            }
        }
        // flag is invalid
        prevROI = nil
        print("ROI flag deactivated due to sufficient speed measurements")
        ROIDeactivatedListCleanup()
    }
    
    /// Performs actions on the measurement list to be done when the ROI flag is deactivated.
    private func ROIDeactivatedListCleanup() {
        processSignificantChanges()
        dumpListToDB(from: 0, to: measurements.count - 1)
        previousLoc = nil // ready for a new session by forgetting last location
    }
    
    /// Called when the ROI countdown for the station expires.
    private func stationTimedOut() {
        self.previousStation = nil
        ROIDeactivatedListCleanup()
    }
    
    /// Called when the ROI countdown for the airport expires.
    private func airportTimedOut() {
        self.previousAirport = nil
        ROIDeactivatedListCleanup()
    }
    
    /// Writes a synthesis of the activities to the database and removes the elements from the measurements.
    private func dumpListToDB(from: Int, to: Int) {
        if from <= to && from >= 0 {
            writeListToDB(from: from, to: to)
            measurements.remove(from: from, to: to)
        }
    }
    
    /// Writes a synthesis of the activities to the database.
    private func writeListToDB(from:Int, to:Int) {
        let synthesis = measurements.synthesize(from: from, to: to)
        if let synthesis = synthesis {
            writeActivityAndUpdateScore(synthesis)
        }
    }
    
    private func writeActivityAndUpdateScore(_ activity: MeasuredActivity) {
        try? DBMS.append(activity: activity)
        try? DBMS.updateScore(activity: activity)
    }
}
