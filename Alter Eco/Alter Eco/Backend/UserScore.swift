import Foundation
import SwiftUI

// Points awarded to userScore for each transport mode
public let WALKING_PTS: Double = 10
public let CAR_PTS: Double = 3
public let TUBE_PTS: Double = 7
public let PLANE_PTS: Double = 0

// ProgressBar Icons number
public let POINTS_REQUIRED_FOR_NEXT_LEAGUE: Double = 3000
public let ICON_ONE: Int = 1
public let ICON_TWO: Int = 2
public let ICON_THREE: Int = 3
public let ICON_FOUR: Int = 4
public let ICON_FIVE: Int = 5
public let NUMBER_OF_ICONS: Double = 6

public class UserScore : Equatable{
    public var totalPoints: Double!
    public var date: String!
    public var league: String!
    
    public static func getInitialScore() -> UserScore {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return UserScore(totalPoints: 0, date: formatter.string(from: Date()), league: "sun.max")
    }
    
    public init(totalPoints: Double, date: String, league: String) {
        self.totalPoints = totalPoints
        self.date = date
        self.league = league
    }
    
    public init(activity: MeasuredActivity, league: String, date: String) {
        self.date = date
        self.totalPoints = UserScore.activityToScore(activity: activity)
        self.league = league
    }
    
    public static func ==(lhs: UserScore, rhs: UserScore) -> Bool {
        return lhs.date == rhs.date && lhs.totalPoints == rhs.totalPoints && lhs.league == rhs.league
    }
    
    // Converts a measured activity to a user score
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
                    return measuredActivityKms * TUBE_PTS
                default:
                    return 0
            }
        }
        return 0
    }
}

/* League Helper Functions */
func getNewLeague(userLeague: String) -> String {

    if userLeague == "sun.max" {
        return "flame.fill"
    }
    else if userLeague == "flame.fill" {
        return "tortoise.fill"
    }
    
    return "tortoise.fill"
}

func getNewLeagueName(leagueName: String) -> String {
    
    if leagueName == "flame.fill" {
        return "flame"
    }
    else if leagueName == "tortoise.fill" {
        return "tortoise"
    }
    
    return "sun"
    
}

func getLeagueProgress() -> Int {
    
    let userScore = try! DBMS.retrieveLatestScore()
    
    if userScore.totalPoints >= POINTS_REQUIRED_FOR_NEXT_LEAGUE {
        try! DBMS.updateLeague(newLeague: getNewLeague(userLeague: userScore.league))
        return 0
    }
    
    return Int(((userScore.totalPoints / POINTS_REQUIRED_FOR_NEXT_LEAGUE) * NUMBER_OF_ICONS).rounded())
}

func getColor(iconNb: Int) -> Color {
    
    if iconNb <= getLeagueProgress() {
        return .blue
    }
    
    return .gray
}
