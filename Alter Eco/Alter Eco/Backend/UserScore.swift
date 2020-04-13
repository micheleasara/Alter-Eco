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

let DBMS : DBManager = (UIApplication.shared.delegate as! AppDelegate).DBMS

public class UserScore {
    public var totalPoints: Double
    public var date: String
    public var league: String
    
    public init(totalPoints: Double, date: String, league: String) {
        self.totalPoints = totalPoints
        self.date = date
        self.league = league
       }
}

func addScoreNewActivity(activity: MeasuredActivity) -> Double {
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

func stringFromDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd" //yyyy
    dateFormatter.locale = Locale(identifier: "en-UK")
    return dateFormatter.string(from: date)
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

/* For new stuff for profile page */

func getCurrentDay() -> Int {
    let date = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day], from: date)
    let dayOfMonth = components.day
    return dayOfMonth!
}

func getLastDayOfPreviousMonth(month: String) -> Int {

    switch month {
        case "01":
            return 31
        case "02":
            return 31
        case "03":
            return 28
        case "04":
            return 31
        case "05":
            return 30
        case "06":
            return 31
        case "07":
            return 30
        case "08":
            return 31
        case "09":
            return 31
        case "10":
            return 30
        case "11":
            return 31
        case "12":
            return 30
        default:
            return 0
    }
}

func getprevMonthDay(currentDay: Int, currentMonth: String) -> Int {
    
    var previousDay: Int = currentDay
    
    if currentDay == 31 || (currentDay == 30 && currentMonth == "03") {
        previousDay = getLastDayOfPreviousMonth(month: currentMonth)
    }
    
    return previousDay
}
