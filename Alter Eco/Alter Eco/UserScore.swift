import Foundation

class UserScore {
    public var totalPoints: Double
    public var date: String
    public var league: String
    
    public init(totalPoints: Double, date: String, league: String) {
        self.totalPoints = totalPoints
        self.date = date
        self.league = league
       }
}
