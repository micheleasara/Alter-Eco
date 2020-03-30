import Foundation
import CoreLocation

public class MeasuredActivity: Equatable {
    // define threshold to identify an automotive type of motion
    // 3.5m/s is 12.6km/h
    public static let AUTOMOTIVE_SPEED_THRESHOLD:Double = 3.5
    // set precision for date equality in seconds
    public static let TIME_PRECISION: Double = 1
    // set precision for distance equality in meters
    public static let SPACE_PRECISION: Double = 0.001

    private static let activityWeights: [MotionType: Int] = [MotionType.car: 2, MotionType.walking: 1]
    
    public enum MotionType{
        case car
        case walking
        case train
        case plane
        case unknown
    }
    
    public var motionType: MotionType
    public var distance: Double
    public var start: Date
    public var end: Date
    
    public init(motionType:MotionType, distance:Double, start:Date, end:Date) {
        self.motionType = motionType
        self.distance = distance
        self.start = start
        self.end = end
    }
    
    public static func ==(lhs: MeasuredActivity, rhs: MeasuredActivity) -> Bool {
        let differenceStart = lhs.start.timeIntervalSince(rhs.start)
        let differenceEnd = lhs.end.timeIntervalSince(rhs.end)
        
        return (lhs.motionType == rhs.motionType &&
            (lhs.distance - rhs.distance < SPACE_PRECISION) &&
            differenceStart < TIME_PRECISION && differenceEnd < TIME_PRECISION)
    }

    public static func getValidMeasuredActivity(location: CLLocation, previousLocation: CLLocation, previousAirport: CLLocation?) -> MeasuredActivity? {
        var measuredActivity:MeasuredActivity? = nil
        // ensure location is accurate enough
        guard location.horizontalAccuracy <= GPS_UPDATE_CONFIDENCE_THRESHOLD else {return nil}
        
        // ensure update happened after roughly GPS_UPDATE_THRESHOLD meters (within tolerance value)
        let distance = location.distance(from: previousLocation).rounded()
        if previousAirport == nil {
            guard distance + GPS_UPDATE_DISTANCE_TOLERANCE >= GPS_UPDATE_DISTANCE_THRESHOLD else {return nil}
        }
        
        // ensure we get no fake instantaneous movements
        let time = location.timestamp.timeIntervalSince(previousLocation.timestamp).rounded()
        guard time > 0 else {return nil}
        
        // calculate parameters
        let speed = distance / time
        let motionType = MeasuredActivity.speedToMotionType(speed: speed)
        measuredActivity = MeasuredActivity(motionType: motionType, distance: distance, start: previousLocation.timestamp, end: location.timestamp)
        
        // if we get here, measured activity is valid
        return measuredActivity
    }

    public static func getAverageActivityDistance(measurements:[MeasuredActivity]) -> Double {
        var distance = 0.0
        for measurement in measurements {
            distance += measurement.distance
        }

        return distance
    }

    public static func getAverageActivityMotionType(measurements:[MeasuredActivity]) -> MotionType {
        var carCounter = 0
        var walkingCounter = 0

        for measurement in measurements {
            if measurement.motionType == MotionType.car {
                carCounter += 1
            }
            else {
                walkingCounter += 1
            }
        }

        if carCounter * activityWeights[.car]! > walkingCounter {
            return MotionType.car
        }
        else {
            return MotionType.walking
        }
    }

    public static func getAverageActivity(measurements:[MeasuredActivity]) -> MeasuredActivity {
        let activity = MeasuredActivity(motionType: getAverageActivityMotionType(measurements: measurements), distance: getAverageActivityDistance(measurements: measurements), start: measurements.first!.start, end: measurements.last!.end)
        return activity
    }

    public static func motionTypeToString(type:MotionType) -> String {
        switch (type) {
            case .car:
                return "car"
            case .walking:
                return "walking"
            case .train:
                return "train"
            case .plane:
                return "plane"
            default:
                return ""
        }
    }

    public static func stringToMotionType(type:String) -> MotionType {
        switch (type) {
            case "car":
                return .car
            case "walking":
                return .walking
            case "train":
                return .train
            case "plane":
                return .plane
            default:
                return .unknown
        }
    }
    
    public static func speedToMotionType(speed:Double) -> MotionType {
        return (speed >= AUTOMOTIVE_SPEED_THRESHOLD) ? .car : .walking
    }
}
