import Foundation
import CoreLocation
import MapKit

public class ActivityEstimator<T:ActivityList> {
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
    // manages countdowns to expire flags for ROI-based activities
    private var timers : CountdownHandler!

    // container for user activities containing a motion type and timestamps
    private var measurements: T
    private let numChangeActivity: Int
        
    public init(activityList: T, numChangeActivity: Int, timers: CountdownHandler) {
        self.measurements = activityList
        self.numChangeActivity = numChangeActivity
        self.timers = timers
    }
    
    public func processLocation(_ location: CLLocation) {
        if isLocationAccurate(location) && isLocationFarEnough(location) && !isLocationUpdateInstantaneous(location) {
            print("valid location received")
            // determine regions of interest
            let currentStation = getCurrentROI(currentLocation: location, regionsOfInterest: self.stations, gpsThreshold: GPS_UPDATE_CONFIDENCE_THRESHOLD)
            let currentAirport = getCurrentROI(currentLocation: location, regionsOfInterest: self.airports, gpsThreshold: GPS_UPDATE_AIRPORT_THRESHOLD)

            // check if we are currently in a train station
            if currentStation != nil {
                processCurrentROI(currentStation!, prevROI: &previousStation, motionType: .train, currentLoc: location)
            }
            // check if we are currently in an airport
            else if currentAirport != nil {
                processCurrentROI(currentAirport!, prevROI: &previousAirport, motionType: .plane, currentLoc: location)
            }
            // not in station and were before, if more than set number of walking measurements, forget flag
            else if currentStation == nil && previousStation != nil && measurements.count > WALK_NUM_FOR_TRAIN_FLAG_OFF {
                checkROIFlagStillValid(activityNumToOff: WALK_NUM_FOR_TRAIN_FLAG_OFF, motionType: .walking, prevROI: &previousStation, currentLoc: location)
            }
            // not in airport and were before, if more than set number of car measurements, forget flag
            else if currentAirport == nil && previousAirport != nil && measurements.count > CAR_NUM_FOR_PLANE_FLAG_OFF {
                checkROIFlagStillValid(activityNumToOff: CAR_NUM_FOR_PLANE_FLAG_OFF, motionType: .car, prevROI: &previousAirport, currentLoc: location)
            }
            // check if there has been a significant change in speed-based activities, and store them if so
            else {
               processSpeedBasedActivities(location: location)
            }
        
            previousLoc = location
        }
    }
    
    private func isLocationAccurate(_ location: CLLocation) -> Bool {
        // accuracy here means phyisical error in meters (the smaller the better)
        return location.horizontalAccuracy <= GPS_UPDATE_CONFIDENCE_THRESHOLD
    }
    
    private func isLocationFarEnough(_ location: CLLocation) -> Bool {
        // ensure update happened after roughly GPS_UPDATE_THRESHOLD meters (within tolerance value)
        guard previousLoc != nil else { return true }
        let distance = location.distance(from: previousLoc!)
        return distance + GPS_UPDATE_DISTANCE_TOLERANCE >= GPS_UPDATE_DISTANCE_THRESHOLD
    }
    
    private func isLocationUpdateInstantaneous(_ location: CLLocation) -> Bool {
        guard previousLoc != nil else { return false }
        return location.timestamp.timeIntervalSince(previousLoc!.timestamp).rounded() <= 0
    }
    
    private func processSpeedBasedActivities(location: CLLocation) {
        // ensure this is not the first location we are receiving
        guard previousLoc != nil else { return }
        addSpeedBasedActivity(location: location, previousLoc: previousLoc!)
        processSignificantChanges()
    }
    
    private func processSignificantChanges() {
        // base case: exit when there are not enough activities for it to be a change
        if measurements.count <= numChangeActivity {
            return
        }
        
        if haveMeasurementsChangedSignificantly() {
            let newActivityIndex = measurements.count - numChangeActivity
            measurements.dumpToDatabase(from: 0, to: newActivityIndex - 1)
        }
        processSignificantChanges()
    }
    
    private func haveMeasurementsChangedSignificantly() -> Bool {
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
    
    private func addSpeedBasedActivity(location: CLLocation, previousLoc: CLLocation) {
        let distance = location.distance(from: previousLoc)
        let time = location.timestamp.timeIntervalSince(previousLoc.timestamp)
        let speed = distance / time
        let motionType = MeasuredActivity.speedToMotionType(speed: speed)
        
        measurements.add(MeasuredActivity(motionType: motionType, distance: distance, start: previousLoc.timestamp, end: location.timestamp))
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
        // check if there was a journey (plane or train)
        if prevROI != nil && currentROI.distance(from: prevROI!).rounded() > 0 {
            let speed = (motionType == .train) ? AVERAGE_TUBE_SPEED : AVERAGE_PLANE_SPEED
            addROIBasedActivity(currentRegionOfInterest: currentROI, previousRegionOfInterest: &prevROI, speed: speed, motionType: motionType)
            resetROITimer(motionType)
        } else {
            // while in same airport/tube station, update timestamp
            if prevROI != nil && currentROI.distance(from: prevROI!).rounded() <= 0 {
                prevROI = CLLocation(coordinate: prevROI!.coordinate, altitude: prevROI!.altitude, horizontalAccuracy: prevROI!.horizontalAccuracy, verticalAccuracy: prevROI!.verticalAccuracy, course: prevROI!.course, speed: prevROI!.speed, timestamp: currentROI.timestamp)
            }
            // In regionOfInterest right now and weren't before
            else if prevROI == nil {
                prevROI = currentROI
                resetROITimer(motionType)
            }
            // compute speed based activity and add it to the list
            if previousLoc != nil {
                addSpeedBasedActivity(location: currentLoc, previousLoc: previousLoc!)
            }
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
        addSpeedBasedActivity(location: currentLoc, previousLoc: previousLoc!)
        
        let newActivityIndex = measurements.count - activityNumToOff
        for i in stride(from: newActivityIndex, to: measurements.count, by: 1) {
            if measurements[i].motionType != motionType {
                return
            }
        }
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
