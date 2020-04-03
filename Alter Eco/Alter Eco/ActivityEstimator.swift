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
    // define max number of measurements stored in memory at a time
    private let maxMeasurements: Int
    // define how many measurements in a row must be different from the root before an activity is averaged
    private let numChangeActivity: Int
    // define how close one has to be to be considered within a station
    private let inStationRadius:Double
    
    public init(numChangeActivity:Int, maxMeasurements:Int, inStationRadius:Double, stationTimeout:Double, airportTimeout:Double) {
        self.maxMeasurements = maxMeasurements
        self.stationTimeout = stationTimeout
        self.airportTimeout = airportTimeout
        self.numChangeActivity = numChangeActivity
        self.inStationRadius = inStationRadius
    }
    
    public func processLocation(_ location: CLLocation) {
        print("received a location")
        // ensure this is not the first location we are receiving
        if let previousLocation = previousLoc {
            let measurement = MeasuredActivity.getValidMeasuredActivity(location: location, previousLocation: previousLocation, previousAirport: previousAirport)
            guard let validMeasurement = measurement else {return}
            measurements.append(validMeasurement)
            
            let currentStation = getCurrentRegionOfInterest(currentLocation: location, regionsOfInterest: self.stations, GPS_THRESHOLD: GPS_UPDATE_CONFIDENCE_THRESHOLD, trackingDataAttribute: 0)
            let currentAirport = getCurrentRegionOfInterest(currentLocation: location, regionsOfInterest: self.airports, GPS_THRESHOLD: GPS_UPDATE_AIRPORT_THRESHOLD, trackingDataAttribute: 1)
                        
//            print("CurrentAirport: ", currentAirport, " and previousAirport: ", previousAirport)
            
            // check if we are not in the same day to break the list, with the exception of the train flag and plane flag
            if previousAirport == nil && previousStation == nil && !inSameDay(date1: previousLocation.timestamp, date2: location.timestamp)  {
                // compute average activity with everything but not last activity, as it is in a different day
                let activity = MeasuredActivity.getAverageActivity(measurements: Array(measurements[..<(measurements.count-1)]))
                // discard last measured activity as it spans two different days
                self.measurements.removeAll()
                appendToDatabase(activity: activity)
            }
                            
            // check if we are currently in a train station
            else if currentStation != nil {
                processCurrentRegionOfInterest(currentStation!, previousRegionOfInterest: &previousStation, computeFunction: computeActivity, speed: AVERAGE_TUBE_SPEED, motionType: .train)
            }
            
            // check if we are currently in an airport
            else if currentAirport != nil {
                processCurrentRegionOfInterest(currentAirport!, previousRegionOfInterest: &previousStation, computeFunction: computeActivity, speed: AVERAGE_PLANE_SPEED, motionType: .plane)
            }
                
            // not in station and were before, if more than 2 walking, forget flag
            else if currentStation == nil && previousStation != nil && measurements.count > numChangeActivity {
                ensureCorrectActivity(numChangeActivity: numChangeActivity, activityScaling: WALK_SCALING, motionType: .walking, previousRegionOfInterest: &previousStation)
            }
            
            // not in airport and were before, if more than 10 car measurements, forget flag
            else if currentAirport == nil && previousAirport != nil && measurements.count > numChangeActivity * CAR_SCALING {
                ensureCorrectActivity(numChangeActivity: numChangeActivity, activityScaling: CAR_SCALING, motionType: .car, previousRegionOfInterest: &previousAirport)
                
            }
                
            // Not in station or airport and weren't before
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
                
    /*-- Tube/Plane functionalities */
    
    private func getCurrentRegionOfInterest(currentLocation: CLLocation, regionsOfInterest: [MKMapItem], GPS_THRESHOLD: Double, trackingDataAttribute: Int) -> CLLocation? {
        for regionOfInterest in regionsOfInterest {
            let regionLocation = CLLocation(latitude: regionOfInterest.placemark.coordinate.latitude, longitude: regionOfInterest.placemark.coordinate.longitude)
            if (regionLocation.distance(from: currentLocation) <= GPS_THRESHOLD) {
                //trackingDataAttribute == 0 ? (trackingData.station = regionOfInterest.name!) : (trackingData.airport = regionOfInterest.name!)
                return regionOfInterest.placemark.location
            }
        }
        //trackingDataAttribute == 0 ? (trackingData.station = "Not in tube station") : (trackingData.airport = "Not in airport")
        return nil
    }
    
    private func processCurrentRegionOfInterest(_ currentRegionOfInterest: CLLocation, previousRegionOfInterest: inout CLLocation?, computeFunction: (CLLocation, inout CLLocation?, Double, MeasuredActivity.MotionType) -> Void, speed: Double, motionType: MeasuredActivity.MotionType){
        // check if there was a journey (plane or tube)
        if previousRegionOfInterest != nil && currentRegionOfInterest.distance(from: previousRegionOfInterest!).rounded() > 0{
            computeFunction(currentRegionOfInterest, &previousRegionOfInterest, speed, motionType)
            motionType == .train ? resetStationTimer() : resetAirportTimer()
        }
            
        // In regionOfInterest right now and weren't before
        else if previousRegionOfInterest == nil {
            previousRegionOfInterest = currentRegionOfInterest
            motionType == .train ? resetStationTimer() : resetAirportTimer()
        }
    }
    
    private func computeActivity(currentRegionOfInterest: CLLocation, previousRegionOfInterest: inout CLLocation?, speed: Double, motionType: MeasuredActivity.MotionType){
        let activityDistance = abs(speed * (previousRegionOfInterest!.timestamp.timeIntervalSince(currentRegionOfInterest.timestamp) - TWO_HOURS_AIRPORT_WAITING_TIME))
        
        // IMPORTANT TO NOTE - In fake trips time is very short between two airports (i.e. 5seconds - 2h * speed = big number of km WRONG)
        print("Tube distance: ", activityDistance)
        let activity = MeasuredActivity(motionType: motionType, distance: activityDistance, start: previousRegionOfInterest!.timestamp, end: currentRegionOfInterest.timestamp)
        self.measurements.removeAll()
        previousRegionOfInterest = currentRegionOfInterest
        appendToDatabase(activity: activity)
    }
    
    private func resetStationTimer(){
        stationValidityTimer.invalidate()
        stationValidityTimer = Timer.scheduledTimer(timeInterval: stationTimeout, target: self, selector: #selector(stationTimedOut(timer:)), userInfo: nil, repeats: false)
    }
    
    private func resetAirportTimer(){
        airportValidityTimer.invalidate()
        airportValidityTimer = Timer.scheduledTimer(timeInterval: airportTimeout, target: self, selector: #selector(airportTimedOut(timer:)), userInfo: nil, repeats: false)
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
    
    @objc private func airportTimedOut(timer: Timer) {
        self.previousAirport = nil
    }
    
    
    private func ensureCorrectActivity(numChangeActivity: Int, activityScaling: Int, motionType: MeasuredActivity.MotionType, previousRegionOfInterest: inout CLLocation?){
        let newActivityIndex = measurements.count - numChangeActivity * activityScaling
        let lastMeasurements = Array(measurements[newActivityIndex...])
        
        let count = lastMeasurements.reduce(0){(count: Int, activity: MeasuredActivity) -> Int in
            count + (activity.motionType == motionType ? 1:0)
        }
         
        if (count >= numChangeActivity * activityScaling) {
            print("Got called")
            previousRegionOfInterest = nil
            computeChangeInActivity()
        }
    }
    
    /*-- END Tube/Plane functionalities --*/
    /*------------------------------------*/
    /*--           General Case         --*/
    
    private func computeChangeInActivity(){
        print("\ncalled\n")
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
}
