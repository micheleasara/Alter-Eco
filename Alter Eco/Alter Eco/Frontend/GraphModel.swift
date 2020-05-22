import Foundation
import SwiftUI
// kg/day
let AV_UK_DAILYCARBON: Double = 2.2

public class DataGraph : ObservableObject {
    @Published var data: [LabelledDataPoints] = getCarbonBreakdown()
    
    public static func getCarbonBreakdown() -> [LabelledDataPoints] {
        return [getDailyData(), getWeeklyData(), getMonthlyData(), getYearlyData()]
    }
     
    public func getMax(i : Int, type: MeasuredActivity.MotionType) -> Double {
        var max = 0.0
        for labelledData in data[i] {
            if let carbon = labelledData.carbonByMotion[type] {
                if carbon > max {
                    max = carbon
                }
            }
        }
        
        return max
    }
    
    public func update() {
        data = DataGraph.getCarbonBreakdown()
    }
}

public typealias CarbonByMotion = Dictionary<MeasuredActivity.MotionType, Double>
public struct LabelledDataPoint : Hashable {
    public var carbonByMotion: CarbonByMotion
    public var label: String
    init(carbonBreakdown: CarbonByMotion, label: String) {
        self.carbonByMotion = carbonBreakdown
        self.label = label
    }
}
public typealias LabelledDataPoints = [LabelledDataPoint]
private func labelledDataFromIntervals(fromDates: [Date], withLabels: [String]) -> LabelledDataPoints {
    var labelledData = LabelledDataPoints()
    let dates = fromDates.sorted()
    for i in stride(from: 1, to: dates.count, by: 1) {
        var carbonOutput = CarbonByMotion()
        for motion in MeasuredActivity.MotionType.allCases {
            let interval = dates[i].timeIntervalSince(dates[i-1])
            let carbon = try! DBMS.carbonWithinInterval(motionType: motion, from: dates[i-1], interval: interval)
            carbonOutput[motion] = carbon
        }
        labelledData.append(LabelledDataPoint(carbonBreakdown: carbonOutput, label: withLabels[i-1]))
    }
    return labelledData
}

public func getDailyData() -> LabelledDataPoints {
    var dates = [Date.setToSpecificHour(date: Date(), hour: "00:00:00")!]
    for i in 0..<12 {
        dates.append(dates[i].addingTimeInterval(2*60*60))
    }
    var labels = [String]()
    for i in stride(from: 2, through: 24, by: 2) {
        let label = i>9 ? String(i) : String(0)+String(i)
        labels.append(label)
    }
    return labelledDataFromIntervals(fromDates: dates, withLabels: labels)
}

public func getWeeklyData() -> LabelledDataPoints {
    var dates = [Date.setToSpecificHour(date: Date().addingTimeInterval(-6*24*60*60), hour: "00:00:00")!]
    var labels = [String(Date.getDayName(dates[0]).prefix(3))]
    for i in 0..<7 {
        dates.append(dates[i].addingTimeInterval(24*60*60))
        labels.append(String(Date.getDayName(dates[i+1]).prefix(3)))
    }
    return labelledDataFromIntervals(fromDates: dates, withLabels: labels)
}

public func getMonthlyData() -> LabelledDataPoints {
    let firstOfMonth = Date.getStartOfMonth(fromDate: Date())
    let start = Date.addMonths(date: firstOfMonth, numMonthsToAdd: -8)
    var dates = [start]
    var labels = [String(Date.getMonthName(dates[0]).prefix(3))]
    for i in 0..<9 {
        dates.append(Date.addMonths(date: dates[i], numMonthsToAdd: 1))
        labels.append(String(Date.getMonthName(dates[i+1]).prefix(3)))
    }
    return labelledDataFromIntervals(fromDates: dates, withLabels: labels)
}

public func getYearlyData() -> LabelledDataPoints {
    let test = Date.setToSpecificDay(date: Date(), day: 1)!
    let firstOfJan = Date.setToSpecificMonth(date: test , month: 1)!
    let start = Date.addMonths(date: firstOfJan, numMonthsToAdd: -6*12)
    
    var dates = [start]
    for i in 0..<6 {
        dates.append(Date.addMonths(date: dates[i], numMonthsToAdd: 12))
    }
    
    return labelledDataFromIntervals(fromDates: dates, withLabels: Date.toYearString(years: dates))
}

#if NO_BACKEND_TESTING
/// Contains data for the graph of GraphView
let dataGraph : DataGraph = DataGraph()
#endif
