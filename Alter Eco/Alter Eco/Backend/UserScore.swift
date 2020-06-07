import Foundation
import SwiftUI

/// Data structure containing all information related to the score of a user.
public class UserScore : Equatable{
    /// Points accumulated so far.
    public var totalPoints: Double!
    /// Date of last update.
    public var date: String!
    /// Current league of the user.
    public var league: String!
    // Current number of trees planted by user
    public var counter: Int!
    
    /// Returns the default initial user score.
    public static func getInitialScore() -> UserScore {
        return UserScore(totalPoints: 0, date: Date().toLocalTime().toInternationalString(), league: "🌱", counter: 0)
    }
    
    /// Initializes a UserScore with the given parameters.
    public init(totalPoints: Double, date: String, league: String, counter: Int) {
        self.totalPoints = totalPoints
        self.date = date
        self.league = league
        self.counter = counter
    }
    
    /// Initializes a UserScore calculating the points from the given activity.
    public init(activity: MeasuredActivity, league: String, date: String, counter: Int) {
        self.date = date
        self.totalPoints = UserScore.activityToScore(activity: activity)
        self.league = league
        self.counter = counter
    }
    
    /// Checks equality between user scores.
    public static func ==(lhs: UserScore, rhs: UserScore) -> Bool {
        return lhs.date == rhs.date && lhs.totalPoints == rhs.totalPoints && lhs.league == rhs.league && lhs.counter == rhs.counter
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
    
    /**
    Returns the user's upgraded league based on current league.
     - Parameter userLeague: the current user's league.
     */
    public static func getNewLeague(userLeague: String) -> String {

        if userLeague == "🌱" {
            return "🌿"
        }
        else if userLeague == "🌿" {
            return "🌳"
        }
        
        else {
            return "🌱"
        }
    }
}



