import Foundation
import CoreLocation
import MapKit

public class ActivityEstimator {
    // environment object used for debugging
    internal var trackingData = TrackingData()
    
    // container for user activities containing a motion type and timestamps
    public var measurements = [MeasuredActivity]()
    // nearby stations
    public var stations: [MKMapItem] = []
    
    // contains location information of visit to tube station, nil if not recently in a tube station
    private var previousStation: CLLocation? = nil
    // contains location from previous valid update
    private var previousLoc: CLLocation? = nil
    // executes countdown for the validity of the train station flag
    private var stationValidityTimer = Timer()
    // seconds after which all train station flags are reset
    private let stationTimeout:Double
    // define max number of measurements stored in memory at a time
    private let maxMeasurements: Int
    // define how many measurements in a row must be different from the root before an activity is averaged
    private let numChangeActivity: Int
    // define how close one has to be to be considered within a station
    private let inStationRadius:Double
    
    public init(numChangeActivity:Int, maxMeasurements:Int, inStationRadius:Double, stationTimeout:Double) {
        self.maxMeasurements = maxMeasurements
        self.stationTimeout = stationTimeout
        self.numChangeActivity = numChangeActivity
        self.inStationRadius = inStationRadius
    }
    
    public func processLocation(_ location: CLLocation) {
        print("received a location")
        // ensure this is not the first location we are receiving
        if let previousLocation = previousLoc {
            let measurement = MeasuredActivity.getValidMeasuredActivity(location: location, previousLocation: previousLocation)
            guard let validMeasurement = measurement else {return}
            measurements.append(validMeasurement)
            let currentStation = getCurrentStation(currentLocation: location, stations: self.stations)
            
            // check if we are not in the same day to break the list, with the exception of the train flag
            if previousStation == nil && !inSameDay(date1: previousLocation.timestamp, date2: location.timestamp)  {
                // compute average activity with everything but not last activity, as it is in a different day
                let activity = MeasuredActivity.getAverageActivity(measurements: Array(measurements[..<(measurements.count-1)]))
                // discard last measured activity as it spans two different days
                self.measurements.removeAll()
                appendToDatabase(activity: activity)
            }
                
            // check if we are currently in a train station
            else if currentStation != nil {
                processCurrentStation(currentStation!)
            }
                
            // not in station and were before, with a sufficient number of measurements
            else if currentStation == nil && previousStation != nil && measurements.count > numChangeActivity {
                let newActivityIndex = measurements.count - numChangeActivity
                let lastMeasurements = Array(measurements[newActivityIndex...])
                let walkingCount = lastMeasurements.reduce(0){(count: Int, activity: MeasuredActivity) -> Int in
                        count + (activity.motionType == .walking ? 1:0)
                    }
                
                if (walkingCount >= numChangeActivity) {
                    previousStation = nil
                    computeChangeInActivity()
                }
            }
                
            // Not in station and weren't before
            else if (hasActivityChangedSignificantly()) {
                computeChangeInActivity()
            }
            else if (isActivityListFull()) {
                let activity = MeasuredActivity.getAverageActivity(measurements: measurements)
                self.measurements.removeAll()
                appendToDatabase(activity: activity)
            }

            // DEBUGGING
            trackingData.distance = validMeasurement.distance
            trackingData.time = validMeasurement.end.timeIntervalSince(validMeasurement.start)
            trackingData.speed = trackingData.distance / trackingData.time
            trackingData.transportMode = MeasuredActivity.motionTypeToString(type: validMeasurement.motionType)
        }
        previousLoc = location
    }
    
    private func getCurrentStation(currentLocation: CLLocation, stations: [MKMapItem]) -> CLLocation? {
        for station in stations {
            let stationLocation = CLLocation(latitude: station.placemark.coordinate.latitude, longitude: station.placemark.coordinate.longitude)
            if (stationLocation.distance(from: currentLocation) <= GPS_UPDATE_CONFIDENCE_THRESHOLD) {
                trackingData.station = station.name!
                return station.placemark.location
            }
        }
        trackingData.station = "Not in tube station"
        return nil
    }
    
    private func processCurrentStation(_ currentStation:CLLocation){
        // check if there was a train journey
        if previousStation != nil && currentStation.distance(from: previousStation!).rounded() > 0{
            computeTrainActivity(currentStation: currentStation)
            resetStationTimer()
        }
            
        // In station right now and weren't before
        else if previousStation == nil {
            previousStation = currentStation
            resetStationTimer()
        }
    }
    
    private func computeTrainActivity(currentStation:CLLocation){
        let tubeDistance = abs(AVERAGE_TUBE_SPEED * previousStation!.timestamp.timeIntervalSince(currentStation.timestamp))
        print("Tube distance: ", tubeDistance)
        let activity = MeasuredActivity(motionType: .train, distance: tubeDistance, start: previousStation!.timestamp, end: currentStation.timestamp)
        self.measurements.removeAll()
        previousStation = currentStation
        appendToDatabase(activity: activity)
    }
    
    private func resetStationTimer(){
        stationValidityTimer.invalidate()
        stationValidityTimer = Timer.scheduledTimer(timeInterval: stationTimeout, target: self, selector: #selector(stationTimedOut(timer:)), userInfo: nil, repeats: false)
    }
    
    private func computeChangeInActivity(){
        let newActivityIndex = measurements.count - numChangeActivity
        let activity = MeasuredActivity.getAverageActivity(measurements: Array(measurements[..<newActivityIndex]))
        appendToDatabase(activity: activity)

        measurements = Array(measurements[newActivityIndex...])
    }
    
    private func hasActivityChangedSignificantly() -> Bool {
        if measurements.count < numChangeActivity {return false}

        let rootType = measurements[0].motionType
        let lastType = measurements.last!.motionType
        let secondLastType = measurements[measurements.count-2].motionType

        return lastType == secondLastType && lastType != rootType
    }
    
    private func isActivityListFull() -> Bool {
        return measurements.count >= maxMeasurements
    }
    
    private func inSameDay(date1:Date, date2:Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.dateComponents([.day, .month, .year], from: date1) == calendar.dateComponents([.day, .month, .year], from: date2)
    }
    
    @objc private func stationTimedOut(timer: Timer) {
        self.previousStation = nil
        var measurementsDay1: [MeasuredActivity] = measurements
        var measurementsDay2: [MeasuredActivity] = []
        for idx in 0..<(measurements.count-1) {
            if !inSameDay(date1: measurements[idx].start, date2: measurements[idx+1].start) {
                measurementsDay1 = Array(measurements[...idx])
                measurementsDay2 = Array(measurements[(idx+1)...])
            }
        }
        let activity = MeasuredActivity.getAverageActivity(measurements: measurementsDay1)
        self.measurements = measurementsDay2
        appendToDatabase(activity: activity)
    }
}
