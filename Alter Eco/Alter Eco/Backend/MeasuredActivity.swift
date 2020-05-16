import Foundation
import CoreLocation

/// Represents the different activities a user can perform.
public class MeasuredActivity : Equatable {
    /// Defines threshold to identify an automotive type of motion in m/s.
    private static let AUTOMOTIVE_SPEED_THRESHOLD:Double = 4
    /// Sets precision for date equality in seconds.
    private static let DATE_TIME_PRECISION: Double = 1
    /// Sets precision for distance equality in meters.
    private static let SPACE_PRECISION: Double = 0.001
    
    /// Possible motion types of a user.
    public enum MotionType : CaseIterable {
        case car
        case walking
        case train
        case plane
        case unknown
    }
    
    /// Motion type associated to this activity.
    public var motionType: MotionType
    /// Distance travelled in this activity.
    public var distance: Double
    /// Start date of the activity.
    public var start: Date
    /// End date of the activity.
    public var end: Date
    
    public init(motionType:MotionType, distance:Double, start:Date, end:Date) {
        self.motionType = motionType
        self.distance = distance
        self.start = start
        self.end = end
    }
    
    /// Checks equality of two activities within tolerance values.
    public static func ==(lhs: MeasuredActivity, rhs: MeasuredActivity) -> Bool {
        let differenceStart = lhs.start.timeIntervalSince(rhs.start)
        let differenceEnd = lhs.end.timeIntervalSince(rhs.end)
        
        return (lhs.motionType == rhs.motionType &&
            (abs(lhs.distance - rhs.distance) < SPACE_PRECISION) &&
            differenceStart < DATE_TIME_PRECISION && differenceEnd < DATE_TIME_PRECISION)
    }

    /// Converts a motion type to a string representation.
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

    /// Converts a correct string representation to a motion type.
    public static func stringToMotionType(type:String) -> MotionType {
        switch (type.lowercased()) {
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
    
    /// Converts a speed value to a motion type for an activity.
    public static func speedToMotionType(speed:Double) -> MotionType {
        return (speed >= AUTOMOTIVE_SPEED_THRESHOLD) ? .car : .walking
    }
}
