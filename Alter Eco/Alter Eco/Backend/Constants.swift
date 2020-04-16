import Foundation

// MARK: - Speed constants
/// Defines the average speed of the tube in London as 33 kmph converted to 9.17 m/s
public let AVERAGE_TUBE_SPEED:Double = 9.17
/// Defines the average plane speed as (740 - 930) kmph, converted to 222 m/s.
public let AVERAGE_PLANE_SPEED:Double = 222

// MARK: - MapKit requests constants
/// Defines radius of search for stations.
public let STATION_REQUEST_RADIUS:Double = 150
/// Defines radius of search for airports.
public let AIRPORTS_REQUEST_RADIUS:Double = 2500
/// Natural language query for train and tube stations nearby.
public let QUERY_TRAIN_STATIONS:String = "underground train subway tube station"
/// Natural language query for airports nearby.
public let QUERY_AIRPORTS: String = "airport"

// MARK: - Region-Of-Interest (ROI) activities constants
/// Defines average radius of airport in meters.
public let MAX_DISTANCE_WITHIN_AIRPORT:Double = 1000
/// Defines average radius of station in meters.
public let MAX_DISTANCE_WITHIN_STATION:Double = 60
/// Idle time (in seconds) after which the activity estimator should forget the user was in a station.
public let STATION_TIMEOUT:Double = 90*60
/// Idle time (in seconds) after which the activity estimator should forget the user was in an airport.
public let AIRPORT_TIMEOUT:Double = 60*60*24
/// Determines how many measurements of type car the activity estimator needs before resetting airport flag.
public let CAR_NUM_FOR_PLANE_FLAG_OFF:Int = 10
/// Determines how many measurements of type walking the activity estimator needs before resetting train flag.
public let WALK_NUM_FOR_TRAIN_FLAG_OFF:Int = 3

// MARK: - Speed-based activities constants
/// Defines how many measurements in a row must be different from the root measurement before an activity is estimated.
public let CHANGE_ACTIVITY_THRESHOLD:Int = 2
/// Defines weights in computing average of speed-based activities.
public let ACTIVITY_WEIGHTS_DICT: [MeasuredActivity.MotionType: Int] = [.car: 2, .walking: 1]
/// Defines how many seconds must pass for an activity to expire in the absence of ROI flags.
public let ACTIVITY_TIMEOUT : Double = 30*60

// MARK: - GPS constants
/// Defines how many meters to request a gps update.
public let GPS_UPDATE_DISTANCE_THRESHOLD:Double = 50
/// Defines tolerance value in meters for gps updates.
public let GPS_UPDATE_DISTANCE_TOLERANCE:Double = 5
/// Defines the minimum confidence for valid location updates.
public let GPS_UPDATE_CONFIDENCE_THRESHOLD:Double = 50
/// Defines the area near airport still considered as an airport location - Paris airport is 5kmx3km
public let GPS_UPDATE_AIRPORT_THRESHOLD:Double = 4000
