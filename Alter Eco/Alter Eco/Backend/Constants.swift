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
public let STATION_TIMEOUT:Double = 90 * 60
/// Idle time (in seconds) after which the activity estimator should forget the user was in an airport.
public let AIRPORT_TIMEOUT:Double = DAY_IN_SECONDS
/// Determines how many measurements of type car the activity estimator needs before resetting airport flag.
public let CAR_NUM_FOR_PLANE_FLAG_OFF:Int = 10
/// Determines how many measurements of type walking the activity estimator needs before resetting train flag.
public let WALK_NUM_FOR_TRAIN_FLAG_OFF:Int = 3

// MARK: - Speed-based activities constants
/// Defines how many measurements in a row must be different from the root measurement before an activity is estimated.
public let CHANGE_ACTIVITY_THRESHOLD:Int = 2
/// Defines the number of speed-based measurements of the same kind which are needed to compute an activity.
public let NUM_MEASUREMENTS_TO_DETERMINE_ACTIVITY = CHANGE_ACTIVITY_THRESHOLD + 1
/// Defines weights in computing average of speed-based activities.
public let ACTIVITY_WEIGHTS_DICT: [MeasuredActivity.MotionType: Double] = [.car: 1.1, .walking: 1]
/// Defines how many seconds must pass for an activity to expire in the absence of ROI flags.
public let ACTIVITY_TIMEOUT : Double = 60 * 5

// MARK: - GPS constants
/// Defines how many meters to request a gps update.
public let GPS_UPDATE_DISTANCE_THRESHOLD:Double = 50
/// Defines tolerance value in meters for gps updates.
public let GPS_UPDATE_DISTANCE_TOLERANCE:Double = 5
/// Defines the minimum confidence for valid location updates.
public let GPS_UPDATE_CONFIDENCE_THRESHOLD:Double = 50
/// Defines the area near airport still considered as an airport location - Paris airport is 5kmx3km
public let GPS_UPDATE_AIRPORT_THRESHOLD:Double = 4000

// MARK: - Carbon conversion constants
/// Carbon output for a car in Kg/Km.
public let CARBON_UNIT_CAR: Double = 0.175
/// Carbon output for a train in Kg/Km.
public let CARBON_UNIT_TRAIN: Double = 0.030
/// Carbon output for a plane in Kg/Km.
public let CARBON_UNIT_PLANE: Double = 0.200
/// Carbon output saved by walking as compared to a car in Kg/Km.
public let CARBON_UNIT_WALKING: Double = 0.175
/// Conversion unit for meters into km.
public let KM_CONVERSION: Double = 0.001

// MARK: - League constants
/// Points for walking.
public let WALKING_PTS: Double = 10
/// Points for car rides.
public let CAR_PTS: Double = 3
/// Points for train rides.
public let TRAIN_PTS: Double = 7
/// Points for flights.
public let PLANE_PTS: Double = 0
/// Number of points needed to pass to the next league.
public let POINTS_REQUIRED_FOR_NEXT_LEAGUE: Double = 3000

// MARK: - Other
/// Average carbon output for a day in the UK in kg/km.
public let AVERAGE_UK_DAILY_CARBON: Double = 2.2
/// Average carbon output for a week in London, in kg.
public let LONDON_AVG_CARBON_WEEK = 15.8
/// One hour in seconds.
public let HOUR_IN_SECONDS: Double = 60 * 60
/// 24 hours in seconds.
public let DAY_IN_SECONDS: Double = 24 * HOUR_IN_SECONDS
/// 168 hours in seconds.
public let WEEK_IN_SECONDS: Double = 7 * DAY_IN_SECONDS
