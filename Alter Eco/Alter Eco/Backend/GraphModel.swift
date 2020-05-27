import Foundation
import SwiftUI

/// Represents the data shown in the graph and can be observed by views wishing to be notified of data changes.
public class GraphDataModel : ObservableObject {
    /// Hour granularity for the daily data.
    public let HOUR_GRANULARITY = 2
    /// Number of weekdays to include in the weekly data.
    public let WEEKDAYS_SHOWN = 7
    /// Number of months to include in the monthly data.
    public let MONTHS_SHOWN = 9
    /// Number of years to include in the yearly data.
    public let YEARS_SHOWN = 5
    
    /// Carbon breakdown by timespans (daily, weekly, monthly, yearly) and means of transport.
    /// Contains labelled data points, where each value is associated with the corresponding time value appropriately formatted.
    @Published public var carbonBreakdown: [CarbonBreakdown]!
    
    public init() {
        update()
    }
    
    /// Fetches the data from the database and updates the observing views.
    public func update() {
        let now = Date()
        carbonBreakdown = [dailyDataUpTo(now),
                            weeklyDataUpTo(now),
                            monthlyDataUpTo(now),
                            yearlyDataUpTo(now)]
    }

    private func dailyDataUpTo(_ last: Date) -> CarbonBreakdown {
        var dates = [Date.setToSpecificHour(date: last, hour: "00:00:00")!]
        for i in 0..<24/HOUR_GRANULARITY {
            let interval = TimeInterval(Double(HOUR_GRANULARITY) * HOUR_IN_SECONDS)
            dates.append(dates[i].addingTimeInterval(interval))
        }
        var labels = [String]()
        for i in stride(from: 0, through: 24, by: HOUR_GRANULARITY) {
            let label = i>9 ? String(i) : String(0)+String(i)
            labels.append(label)
        }
        return breakdownFromDateRanges(rangesBoundaries: dates, withLabels: labels)
    }

    private func weeklyDataUpTo(_ last: Date) -> CarbonBreakdown {
        let numDaysAgo = Double((WEEKDAYS_SHOWN - 1))
        var dates = [Date.setToSpecificHour(date:
                     last.addingTimeInterval(-numDaysAgo * DAY_IN_SECONDS), hour: "00:00:00")!]
        var labels = [String(Date.getDayName(dates[0]).prefix(3))]
        
        for i in 0..<WEEKDAYS_SHOWN {
            dates.append(dates[i].addingTimeInterval(DAY_IN_SECONDS))
            labels.append(String(Date.getDayName(dates[i+1]).prefix(3)))
        }
        return breakdownFromDateRanges(rangesBoundaries: dates, withLabels: labels)
    }

    private func monthlyDataUpTo(_ last: Date) -> CarbonBreakdown {
        // start from the first month shown at midnight
        let monthStart = Date.getStartOfMonth(fromDate: last)
        let start = Date.addMonths(date: monthStart, numMonthsToAdd: -(MONTHS_SHOWN - 1))
        
        // last date added is the first of next month at midnight
        var dates = [start]
        var labels = [String(Date.getMonthName(dates[0]).prefix(3))]
        for i in stride(from: 0, to: MONTHS_SHOWN, by: 1) {
            dates.append(Date.addMonths(date: dates[i], numMonthsToAdd: 1))
            labels.append(String(Date.getMonthName(dates[i+1]).prefix(3)))
        }
        return breakdownFromDateRanges(rangesBoundaries: dates, withLabels: labels)
    }

    private func yearlyDataUpTo(_ last: Date) -> CarbonBreakdown {
        // start from the first year shown on the 1st of Jan at midnight
        let monthStart = Date.getStartOfMonth(fromDate: last)
        let firstOfJan = Date.setToSpecificMonth(date: monthStart, month: 1)!
        let start = Date.addMonths(date: firstOfJan, numMonthsToAdd: -(YEARS_SHOWN - 1) * 12)
        
        // last date added is the first of next year at midnight
        var dates = [start]
        var labels = [Date.getYearAsString(dates[0])]
        for i in stride(from: 0, to: YEARS_SHOWN, by: 1) {
            dates.append(Date.addMonths(date: dates[i], numMonthsToAdd: 12))
            labels.append(Date.getYearAsString(dates[i+1]))
        }
        
        return breakdownFromDateRanges(rangesBoundaries: dates, withLabels: labels)
    }
    
    private func breakdownFromDateRanges(rangesBoundaries: [Date],
                                               withLabels: [String]) -> CarbonBreakdown {
        let dates = rangesBoundaries.sorted()
        let intervals = intervalsFromDateRanges(boundaries: rangesBoundaries)
        
        var carbonBreakdown = CarbonBreakdown()
        var dataTotal = LabelledDataPoints() // carbon for all motions combined
        for motion in MeasuredActivity.MotionType.allCases {
            var dataMotion = LabelledDataPoints()
            for i in stride(from: 1, to: dates.count, by: 1) {
                let carbon = try! DBMS.carbonWithinInterval(motionType: motion, from: dates[i-1], interval: intervals[i-1])
                dataMotion.append(LabelledDataPoint(data: carbon, label: withLabels[i-1]))
                
                if dataTotal.count > i-1 {
                    dataTotal[i-1].data += carbon
                } else { // not initialised
                    dataTotal.append(LabelledDataPoint(data: carbon, label: withLabels[i-1]))
                }
            }
            carbonBreakdown[motion] = dataMotion
        }
        carbonBreakdown[.unknown] = dataTotal
        
        return carbonBreakdown
    }
    
    private func intervalsFromDateRanges(boundaries: [Date]) -> [TimeInterval] {
        var intervals = [TimeInterval]()
        for i in stride(from: 1, to: boundaries.count, by: 1) {
            intervals.append(boundaries[i].timeIntervalSince(boundaries[i-1]))
        }
        return intervals
    }
}

#if NO_BACKEND_TESTING
/// Contains data for the graph of GraphView
let dataGraph : GraphDataModel = GraphDataModel()
#endif
