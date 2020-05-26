import Foundation
import SwiftUI
// kg/day
let AV_UK_DAILYCARBON: Double = 2.2

public class GraphDataModel : ObservableObject {
    @Published public var data: [CarbonBreakdown] = getCarbonBreakdown()
    
    public static func getCarbonBreakdown() -> [CarbonBreakdown] {
        return [DBMS.getDailyData(), DBMS.getWeeklyData(), DBMS.getMonthlyData(), DBMS.getYearlyData()]
    }
    
    public func update() {
        data = GraphDataModel.getCarbonBreakdown()
    }
}

#if NO_BACKEND_TESTING
/// Contains data for the graph of GraphView
let dataGraph : GraphDataModel = GraphDataModel()
#endif
