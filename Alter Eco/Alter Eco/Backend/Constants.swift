import Foundation

// MARK: - Speed constants
// define the average speed of the tube in London as 33 kmph converted to 9.17 m/s
public let AVERAGE_TUBE_SPEED:Double = 9.17
// define average plane speed as (740 - 930) kmph converted to 222 m/s
public let AVERAGE_PLANE_SPEED:Double = 222

// MARK: - MapKit requests constants
// define radius of search for stations
public let STATION_REQUEST_RADIUS:Double = 150
// define radius of search for airports
public let AIRPORTS_REQUEST_RADIUS:Double = 2500
// natural language query for train and tube stations nearby
public let QUERY_TRAIN_STATIONS:String = "underground train subway tube station"
// natural language query for airports nearby
public let QUERY_AIRPORTS: String = "airport"

// MARK: - Region-Of-Interest (ROI) activities constants
// define average radius of airport m
public let MAX_DISTANCE_WITHIN_AIRPORT:Double = 1000
// define average radius of station m
public let MAX_DISTANCE_WITHIN_STATION:Double = 60
// idle time (in seconds) after which the activity estimator should forget the user was in a station
public let STATION_TIMEOUT:Double = 90*60
// idle time (in seconds) after which the activity estimator should forget the user was in an airport
public let AIRPORT_TIMEOUT:Double = 60*60*24
// used for plane motion type, determines how many measurements of type car needed before resetting airport flag
public let CAR_NUM_FOR_PLANE_FLAG_OFF:Int = 10
// used for tube motion type, determines how many measurements of type walking needed before resetting train flag
public let WALK_NUM_FOR_TRAIN_FLAG_OFF:Int = 3

// MARK: - Speed-based activities constants
// define how many measurements in a row must be different from the root measurement before an activity is estimated
public let CHANGE_ACTIVITY_THRESHOLD:Int = 2
// defines weights in computing average of speed-based activities
public let ACTIVITY_WEIGHTS_DICT: [MeasuredActivity.MotionType: Int] = [.car: 2, .walking: 1]

// MARK: - GPS constants
// defines how many meters to request a gps update
public let GPS_UPDATE_DISTANCE_THRESHOLD:Double = 50
// define tolerance value in meters for gps updates
public let GPS_UPDATE_DISTANCE_TOLERANCE:Double = 5
// define minimum confidence for valid location updates
public let GPS_UPDATE_CONFIDENCE_THRESHOLD:Double = 50
// define area near airport still considered as an airport location - Paris airport 5kmx3km
public let GPS_UPDATE_AIRPORT_THRESHOLD:Double = 4000
