import SwiftUI

struct AwardView: View {
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    @ObservedObject var awardsManager: AwardsManager
    
    var body: some View {
        ForEach(awardsManager.awards) { award in
            ZStack{
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color("fill_colour"))
                HStack {
                    VStack{
                        Text(award.Name).font(.headline)

                        Text(award.Description).font(.caption)
                    }.frame(width: self.screenMeasurements.trasversal*0.5, alignment: .center)
                                   
                    Image(award.Awarded ? award.BadgeTitle : "badge_empty")
                        .frame(width: self.screenMeasurements.trasversal*0.22, height: self.screenMeasurements.trasversal*0.22, alignment: .center)
                        .scaleEffect(self.screenMeasurements.trasversal/1200)
                }
            }
            .opacity(award.Awarded ? 1.0 : 0.6)
            .frame(width: self.screenMeasurements.trasversal*0.9, height: self.screenMeasurements.trasversal*0.3)
        }
    }
}

public class AwardsManager: ObservableObject {
    @Published public var awards: [Awards]!
    public var DBMS: DBManager!
    
    public init(DBMS: DBManager) {
        self.DBMS = DBMS
    }
}

public class FoodAwardsManager: AwardsManager {
    public override init(DBMS: DBManager) {
        super.init(DBMS: DBMS)
        updateAwards()
    }
    
    public func updateAwards() {
        setAwardsValidity()
        awards = [Awards(
                id: 5,
                name: "Contributor",
                description: "Add 5 new items to the database",
                badgeTitle: "badge_plane",
                awarded: UserDefaults.standard.bool(forKey: String(5))
            ),
            Awards(
                id: 6,
                name: "Super contributor",
                description: "Add 10 new items to the database",
                badgeTitle: "super_contributor",
                awarded: UserDefaults.standard.bool(forKey: String(6))
            )]
    }
    
    private func setAwardsValidity() {
        // TODO: implementation
    }
}

public class TransportAwardsManager: AwardsManager {
    public override init(DBMS: DBManager) {
        super.init(DBMS: DBMS)
        updateAwards()
    }
    
    public func updateAwards() {
        setAwardsValidity()
        awards = [Awards(
                id: 0,
                name: "Bye-Flyer",
                description: "No airplane travel for 6 months",
                badgeTitle: "badge_plane",
                awarded: UserDefaults.standard.bool(forKey: String(0))
            ),
            Awards(
                id: 1,
                name: "Beating the Average",
                description: "Used less carbon than the London average for one week",
                badgeTitle: "badge_london",
                awarded: UserDefaults.standard.bool(forKey: String(1))
            ),
            Awards(
                id: 2,
                name: "Walker",
                description: "Walked more than 10 kms in a week",
                badgeTitle: "badge_feet",
                awarded: UserDefaults.standard.bool(forKey: String(2))
            ),
            Awards(
                id: 3,
                name: "No Wheels",
                description: "No car or bus travel for one month",
                badgeTitle: "badge_wheels",
                awarded: UserDefaults.standard.bool(forKey: String(3))
            ),
            Awards(
                id: 4,
                name: "COVID-19",
                description: "Travelled less than 300m in a week",
                badgeTitle: "badge_crown",
                awarded: UserDefaults.standard.bool(forKey: String(4))
            )]
    }
    
    private func setAwardsValidity() {
        let now = Date()
        let originalDate = (try? DBMS.getFirstDate()) ?? now
        let timeInterval = now.timeIntervalSince(originalDate)

        if (try! DBMS.carbonWithinInterval(motionType:MeasuredActivity.MotionType.plane, from: now, interval: -183*DAY_IN_SECONDS) == 0 && timeInterval > (30*DAY_IN_SECONDS*6)) {
            UserDefaults.standard.set(true, forKey: String(0))
        }
        
        if (try! DBMS.carbonFromPollutingMotions(from: now, interval: -WEEK_IN_SECONDS) < LONDON_AVG_CARBON_WEEK && timeInterval > WEEK_IN_SECONDS) {
            UserDefaults.standard.set(true, forKey: String(1))
        }
        
        if (try! DBMS.distanceWithinInterval(motionType: MeasuredActivity.MotionType.walking, from: now, interval: -WEEK_IN_SECONDS) > 10000 && timeInterval > WEEK_IN_SECONDS) {
            UserDefaults.standard.set(true, forKey: String(2))
        }
        
        if (try! DBMS.carbonWithinInterval(motionType: MeasuredActivity.MotionType.car, from: now, interval: -30*DAY_IN_SECONDS) == 0 && timeInterval > 30*DAY_IN_SECONDS) {
            UserDefaults.standard.set(true, forKey: String(3))
        }
        
        if (try! DBMS.distanceWithinIntervalAll(from: now, interval: -30*DAY_IN_SECONDS) < 300 && timeInterval > 30*DAY_IN_SECONDS) {
            UserDefaults.standard.set(true, forKey: String(4))
        }
    }
}

public struct Awards: Identifiable, Codable {
    public let id: Int
    public let Name: String
    public let Description: String
    public let BadgeTitle: String
    public var Awarded: Bool
    
    public init(id: Int, name: String, description: String, badgeTitle: String, awarded: Bool = false) {
        self.id = id
        self.Name = name
        self.Description = description
        self.BadgeTitle = badgeTitle
        self.Awarded = awarded
    }
}
