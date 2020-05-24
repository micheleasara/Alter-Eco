import Foundation
import SwiftUI
// kg/day
let AV_UK_DAILYCARBON: Double = 2.2

public class DataGraph : ObservableObject {
    @Published var data: [CarbonBreakdown] = getCarbonBreakdown()
    
    public static func getCarbonBreakdown() -> [CarbonBreakdown] {
        return [getDailyData(), getWeeklyData(), getMonthlyData(), getYearlyData()]
    }
    
    public func update() {
        data = DataGraph.getCarbonBreakdown()
    }
}

public struct LabelledDataPoint : Hashable {
    public var data: Double
    public var label: String
    init(data: Double, label: String) {
        self.data = data
        self.label = label
    }
}
public typealias CarbonBreakdown = Dictionary<MeasuredActivity.MotionType, LabelledDataPoints>
public typealias LabelledDataPoints = [LabelledDataPoint]
private func carbonBreakdownFromIntervals(fromDates: [Date], withLabels: [String]) -> CarbonBreakdown {
    let dates = fromDates.sorted()
    
    var intervals = [TimeInterval]()
    for i in stride(from: 1, to: dates.count, by: 1) {
        intervals.append(dates[i].timeIntervalSince(dates[i-1]))
    }
    
    var carbonBreakdown = CarbonBreakdown()
    for motion in MeasuredActivity.MotionType.allCases {
        var labelledData = LabelledDataPoints()
        for i in stride(from: 1, to: dates.count, by: 1) {
            let carbon = try! DBMS.carbonWithinInterval(motionType: motion, from: dates[i-1], interval: intervals[i-1])
            labelledData.append(LabelledDataPoint(data: carbon, label: withLabels[i-1]))
        }
        carbonBreakdown[motion] = labelledData
        carbonBreakdown[.unknown] = labelledData
    }
    return carbonBreakdown
}

public func getDailyData() -> CarbonBreakdown {
    var dates = [Date.setToSpecificHour(date: Date(), hour: "00:00:00")!]
    for i in 0..<12 {
        dates.append(dates[i].addingTimeInterval(2*60*60))
    }
    var labels = [String]()
    for i in stride(from: 0, through: 24, by: 2) {
        let label = i>9 ? String(i) : String(0)+String(i)
        labels.append(i % 4 == 0 ? label : "")
    }
    return carbonBreakdownFromIntervals(fromDates: dates, withLabels: labels)
}

public func getWeeklyData() -> CarbonBreakdown {
    var dates = [Date.setToSpecificHour(date: Date().addingTimeInterval(-6*24*60*60), hour: "00:00:00")!]
    var labels = [String(Date.getDayName(dates[0]).prefix(3))]
    for i in 0..<7 {
        dates.append(dates[i].addingTimeInterval(24*60*60))
        labels.append(String(Date.getDayName(dates[i+1]).prefix(3)))
    }
    return carbonBreakdownFromIntervals(fromDates: dates, withLabels: labels)
}

public func getMonthlyData() -> CarbonBreakdown {
    let firstOfMonth = Date.getStartOfMonth(fromDate: Date())
    let start = Date.addMonths(date: firstOfMonth, numMonthsToAdd: -8)
    var dates = [start]
    var labels = [String(Date.getMonthName(dates[0]).prefix(3))]
    for i in 0..<9 {
        dates.append(Date.addMonths(date: dates[i], numMonthsToAdd: 1))
        labels.append(String(Date.getMonthName(dates[i+1]).prefix(3)))
    }
    return carbonBreakdownFromIntervals(fromDates: dates, withLabels: labels)
}

public func getYearlyData() -> CarbonBreakdown {
    let test = Date.setToSpecificDay(date: Date(), day: 1)!
    let firstOfJan = Date.setToSpecificMonth(date: test , month: 1)!
    let start = Date.addMonths(date: firstOfJan, numMonthsToAdd: -5*12)
    
    var dates = [start]
    for i in 0..<6 {
        dates.append(Date.addMonths(date: dates[i], numMonthsToAdd: 12))
    }
    
    return carbonBreakdownFromIntervals(fromDates: dates, withLabels: Date.toYearString(years: dates))
}

#if NO_BACKEND_TESTING
/// Contains data for the graph of GraphView
let dataGraph : DataGraph = DataGraph()
#endif
