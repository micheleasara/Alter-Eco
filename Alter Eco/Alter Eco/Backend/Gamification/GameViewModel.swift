import SwiftUI

/// Responsible for publishing data relevant to the game view.
public class GameViewModel: ObservableObject {
    /// Determines whether the user can move forest items.
    @Published public var isEditModeOn: Bool = false
    /// Represents an item which the user is in the process of adding.
    @Published public var itemToAdd: ShopItem?
    /// Determines if the smog effect is enabled or not.
    @Published public var isSmogOn: Bool = false
    /// Determines if the 3D scene should be shown or not.
    public var isGameOn: Bool {
        willSet {
            objectWillChange.send()
            // refresh smog state everytime we open the game
            if newValue {
                refreshSmogState()
                print("smog is \(isSmogOn)")
            }
        }
    }
    
    /// interacts with the database.
    private let DBMS: DBManager
    
    /// Initializes a new instance of this view model using the database manager provided.
    public init(DBMS: DBManager) {
        self.DBMS = DBMS
        isGameOn = false
    }
    
    /**
     Returns true if the user has more or the same amount of points compared to the value provided.
     - Parameter requiredPts: the value which is compared against the amount of points stored in the database.
     */
    public func hasEnoughPoints(requiredPts: Double) -> Bool {
        if let currentPts = try? DBMS.retrieveLatestScore() {
            return currentPts >= requiredPts
        }
        return false
    }
    
    /// Queries the database and sets the smog state appropriately.
    public func refreshSmogState() {
        let start = Date().toLocalTime().setToSpecificHour(hour: "00:00:00")?.toGlobalTime() ?? Date()
        if let dailyTotal = (try? DBMS.carbonWithinInterval(from: start, addingInterval: DAY_IN_SECONDS))?.value {
            isSmogOn = dailyTotal > AVERAGE_UK_DAILY_CARBON
        }
    }
    
    /// Returns a controller which handles 3D rendering and other game-related activities.
    public func getViewController() -> GameViewController {
        return GameViewController(mainScenePath: "MainScene.scn", DBMS: DBMS)
    }
}
