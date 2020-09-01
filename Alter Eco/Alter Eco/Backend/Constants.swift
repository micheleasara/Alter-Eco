import Foundation

// MARK: - GPS constants
/// Defines how many meters to request a gps update.
public let GPS_DISTANCE_THRESHOLD: Double = 50
/// Defines tolerance value in meters for gps updates.
public let GPS_DISTANCE_TOLERANCE: Double = 5
/// Defines the minimum confidence in meters for valid location updates. Updates with horizontal accuracy below this value are ignored.
public let GPS_CONFIDENCE_THRESHOLD: Double = 35
/// Defines the maximum altitude for a GPS update to be considered valid.
public let GPS_MAX_ALTITUDE: Double = 6000

// MARK: - MapKit requests constants
/// Defines radius of search for stations in meters.
public let STATION_REQUEST_RADIUS: Double = 1.5*GPS_DISTANCE_THRESHOLD
/// Defines the maximum radius in meters for a map request related to airports.
public var MAX_AIRPORT_REQUEST_RADIUS: Double = 2500
/// Defines the minimum radius in meters for a map request related to airports.
public var MIN_AIRPORT_REQUEST_RADIUS: Double = STATION_REQUEST_RADIUS
/// Natural language query for train and tube stations nearby.
public let QUERY_TRAIN_STATIONS: String = "train station"
/// Natural language query for airports nearby.
public let QUERY_AIRPORTS: String = "airport"

// MARK: - Region-Of-Interest (ROI) activities constants
/// Defines minimum distance in meters between two airports for a flight to have occurred.
public let MIN_DISTANCE_FOR_FLIGHT: Double = 3500
/// Defines minimum distance in meters between two stations for a trip to have occurred.
public let MIN_DISTANCE_TRAIN_TRIP: Double = GPS_DISTANCE_THRESHOLD
/// Idle time (in seconds) after which the activity estimator should forget the user was in a station.
public let STATION_TIMEOUT: Double = 90 * 60
/// Idle time (in seconds) after which the activity estimator should forget the user was in an airport.
public let AIRPORT_TIMEOUT: Double = 20 * HOUR_IN_SECONDS
/// Determines how many measurements of type car the activity estimator needs in a row before resetting airport flag.
public let CAR_NUM_FOR_PLANE_FLAG_OFF: Int = 15
/// Determines how many measurements of type walking the activity estimator needs in a row before resetting train flag.
public let WALK_NUM_FOR_TRAIN_FLAG_OFF: Int = 4
/// Defines the average speed of the tube in London as 33 kmph converted to 9.17 m/s
public let AVERAGE_TUBE_SPEED:Double = 9.17
/// Defines the average plane speed as (740 - 930) kmph, converted to 222 m/s.
public let AVERAGE_PLANE_SPEED:Double = 222

// MARK: - Speed-based activities constants
/// Defines how many measurements in a row must be different from the root measurement before an activity is estimated.
public let CHANGE_ACTIVITY_THRESHOLD: Int = 2
/// Defines the number of speed-based measurements of the same kind which are needed to compute an activity.
public let NUM_MEASUREMENTS_TO_DETERMINE_ACTIVITY = CHANGE_ACTIVITY_THRESHOLD + 1
/// Defines weights in computing average of speed-based activities.
public let ACTIVITY_WEIGHTS_DICT: [MeasuredActivity.MotionType: Double] = [.car: 1.1, .walking: 1]
/// Defines how many seconds must pass for an activity to expire in the absence of ROI flags.
public let ACTIVITY_TIMEOUT: Double = 60 * 5
/// Defines the maximum speed allowed for a speed-based measurement to be considered valid in m/s.
public let MAX_SPEED: Double = 0.4*AVERAGE_PLANE_SPEED
/// Defines the default cycling speed in m/s if the user enabled cycling.
public let DEFAULT_CYCLE_SPEED: Double = 6
/// Defines threshold to identify an automotive type of motion in m/s.
public let AUTOMOTIVE_SPEED_THRESHOLD:Double = 4

// MARK: - Carbon conversion constants
/// Carbon output for a car in kg/km.
public let CARBON_UNIT_CAR: Double = 0.175
/// Carbon output for a train in kg/km.
public let CARBON_UNIT_TRAIN: Double = 0.030
/// Carbon output for a plane in kg/km.
public let CARBON_UNIT_PLANE: Double = 0.200
/// Carbon output saved by walking as compared to a car in kg/km.
public let CARBON_UNIT_WALKING: Double = 0.175
/// Conversion unit for meters into km.
public let KM_CONVERSION: Double = 0.001

// all the constants for carbon conversions come from:
// https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2019
// all units have been converted to kilogram/kilometer

// MARK: - Points constants
/// Points for walking per km.
public let WALKING_PTS: Double = 10
/// Points for car rides per km.
public let CAR_PTS: Double = 3
/// Points for train rides per km.
public let TRAIN_PTS: Double = 7
/// Points for flights per km.
public let PLANE_PTS: Double = 0
/// Points for the first food scan of the day.
public let FIRST_FOOD_SCAN_PTS = 15

// MARK: - Other
/// Average carbon output for a day in the UK in kg.
public let AVERAGE_UK_DAILY_CARBON: Double = 13.7
/// Average carbon output for a week in London in kg.
public let LONDON_AVG_CARBON_WEEK_TRANSPORT = 15.8
/// One hour in seconds.
public let HOUR_IN_SECONDS: Double = 60 * 60
/// 24 hours in seconds.
public let DAY_IN_SECONDS: Double = 24 * HOUR_IN_SECONDS
/// 168 hours in seconds.
public let WEEK_IN_SECONDS: Double = 7 * DAY_IN_SECONDS
