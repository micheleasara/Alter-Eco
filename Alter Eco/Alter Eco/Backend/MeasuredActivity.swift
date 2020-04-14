import Foundation
import CoreLocation

public class MeasuredActivity : Equatable {
    // define threshold to identify an automotive type of motion in m/s
    public static let AUTOMOTIVE_SPEED_THRESHOLD:Double = 4
    // set precision for date equality in seconds
    public static let TIME_PRECISION: Double = 1
    // set precision for distance equality in meters
    public static let SPACE_PRECISION: Double = 0.001
    
    public enum MotionType : CaseIterable {
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
