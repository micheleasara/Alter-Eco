import SwiftUI

/// Responsible for publishing data relevant to the game view.
public class GameViewModel: ObservableObject {
    /// Determines whether the user can move forest items.
    @Published public var isEditModeOn: Bool = false
    /// The name of the item which the user will be allowed to add to the forest. Nil if the user is not in the process of placing a new item.
    @Published public var nameItemToAdd: String?
    /// Determines if the smog effect is enabled or not.
    @Published public var isSmogOn: Bool = false
    /// Determines if the 3D scene should be shown or not.
    @Published public var isGameOn: Bool = false
    /// interacts with the database.
    private let DBMS: DBManager
    
    /// Initializes a new instance of this view model using the database manager provided.
    public init(DBMS: DBManager) {
        self.DBMS = DBMS
    }
    
    /**
     Returns true if the user has more or the same amount of points compared to the value provided.
     - Parameter requiredPts: the value which is compared against the amount of points stored in the database.
     */
    public func hasEnoughPoints(requiredPts: Double) -> Bool {
        if let currentPts = try? DBMS.retrieveLatestScore() {
            return currentPts.totalPoints >= requiredPts
        }
        return false
    }
    
    /// Returns a controller which handles 3D rendering and other game-related activities.
    public func getViewController() -> GameViewController {
        return GameViewController(mainScenePath: "MainScene.scn", DBMS: DBMS)
    }
}
