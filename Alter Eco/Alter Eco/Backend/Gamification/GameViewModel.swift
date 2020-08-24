import SwiftUI

/// Responsible for publishing data relevant to the game view.
public class GameViewModel: ObservableObject {
    /// The currently available points.
    @Published public var currentPoints: Double = 0
    /// Determines whether the user can move forest items.
    @Published public var isEditModeOn: Bool = false
    /// Represents an item which the user is in the process of adding.
    @Published public var itemToAdd: ShopItem?
    /// Determines if the smog effect is enabled or not.
    @Published public var isSmogOn: Bool = false
    /// Determines if the 3D scene should be shown or not.
    public var isGameOn: Bool {
        willSet {
            objectWillChange.send() // emulate @Published
            // refresh smog state everytime we open the game
            if newValue {
                refreshSmogState()
            }
        }
    }
    
    /// interacts with the database.
    private let DBMS: DBManager
    
    /// Initializes a new instance of this view model using the database manager provided.
    public init(DBMS: DBManager) {
        self.DBMS = DBMS
        isGameOn = false
        refreshCurrentPoints()
    }
    
    /// Queries the database and sets the smog state appropriately.
    public func refreshSmogState() {
        let start = Date().toLocalTime().setToSpecificHour(hour: "00:00:00")?.toGlobalTime() ?? Date()
        if let dailyTotal = (try? DBMS.carbonWithinInterval(from: start, addingInterval: DAY_IN_SECONDS))?.value {
            isSmogOn = dailyTotal > AVERAGE_UK_DAILY_CARBON
        }
    }
    
    /// Queries the database and sets the current points to the most recent value.
    public func refreshCurrentPoints() {
        if let points = try? DBMS.retrieveLatestScore() {
            currentPoints = points
        }
    }
}
