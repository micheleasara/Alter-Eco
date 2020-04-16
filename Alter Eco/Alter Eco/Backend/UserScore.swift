import Foundation
import SwiftUI

/// Points for walking.
public let WALKING_PTS: Double = 10
/// Points for car rides.
public let CAR_PTS: Double = 3
/// Points for train rides.
public let TRAIN_PTS: Double = 7
/// Points for flights.
public let PLANE_PTS: Double = 0

// ProgressBar Icons number
public let POINTS_REQUIRED_FOR_NEXT_LEAGUE: Double = 3000

/// Data structure containing all information related to the score of a user.
public class UserScore : Equatable{
    /// Points accumulated so far.
    public var totalPoints: Double!
    /// Date of last update.
    public var date: String!
    /// Current league of the user.
    public var league: String!
    
    /// Returns the default initial user score.
    public static func getInitialScore() -> UserScore {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return UserScore(totalPoints: 0, date: dateFormatter.string(from: Date()), league: "🌱")
    }
    
    /// Initializes a UserScore with the given parameters.
    public init(totalPoints: Double, date: String, league: String) {
        self.totalPoints = totalPoints
        self.date = date
        self.league = league
    }
    
    /// Initializes a UserScore calculating the points from the given activity.
    public init(activity: MeasuredActivity, league: String, date: String) {
        self.date = date
        self.totalPoints = UserScore.activityToScore(activity: activity)
        self.league = league
    }
    
    /// Checks equality between user scores.
    public static func ==(lhs: UserScore, rhs: UserScore) -> Bool {
        return lhs.date == rhs.date && lhs.totalPoints == rhs.totalPoints && lhs.league == rhs.league
    }
    
    /// Converts an activity to a user score.
    private static func activityToScore(activity: MeasuredActivity) -> Double {
        let measuredActivityKms = activity.distance * KM_CONVERSION
        
        if measuredActivityKms != 0 {
            switch activity.motionType {
                case .car:
                    return measuredActivityKms * CAR_PTS
                case .walking:
                    return measuredActivityKms * WALKING_PTS
                case .plane:
                    return measuredActivityKms * PLANE_PTS
                case .train:
                    return measuredActivityKms * TRAIN_PTS
                default:
                    return 0
            }
        }
        return 0
    }
}

/* League Helper Functions */
func getNewLeague(userLeague: String) -> String {

    if userLeague == "🌱" {
        return "🌿"
    }
    else if userLeague == "🌿" {
        return "🌳"
    }
    
    return "🌳"
}

func getLeagueProgress() -> Void {
    
    let userScore = try! DBMS.retrieveLatestScore()
    
    if userScore.totalPoints >= POINTS_REQUIRED_FOR_NEXT_LEAGUE {
        try! DBMS.updateLeague(newLeague: getNewLeague(userLeague: userScore.league))
    }
}


