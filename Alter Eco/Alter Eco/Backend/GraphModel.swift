import Foundation
import SwiftUI

/// Represents a value associated to a label.
public struct LabelledDataPoint : Hashable {
    public var data: Double
    public var label: String
    init(data: Double, label: String) {
        self.data = data
        self.label = label
    }
}
/// A collection of values associated to a label.
public typealias LabelledDataPoints = [LabelledDataPoint]

/// A container for carbon values divided by motion type and associated to a label.
public typealias CarbonBreakdown = Dictionary<MeasuredActivity.MotionType, LabelledDataPoints>

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
    @Published public var carbonBreakdown = Dictionary<Timespan, CarbonBreakdown>()
    
    private let DBMS: DBManager!
    
    /// Initializes a new graph model which fetches data up to the limit provided and with the DBManager given.
    public init(limit: Date, DBMS: DBManager) {
        self.DBMS = DBMS
        updateUpTo(limit)
    }
    
    /// Fetches the data from the database and updates the observing views.
    public func updateUpTo(_ date: Date) {
        carbonBreakdown[.day] = dailyDataUpTo(date)
        carbonBreakdown[.week] = weeklyDataUpTo(date)
        carbonBreakdown[.month] = monthlyDataUpTo(date)
        carbonBreakdown[.year] = yearlyDataUpTo(date)
    }

    /// Represents the timespans shown in the graph.
    public enum Timespan: CaseIterable {
        case day
        case week
        case month
        case year
    }
    
    /// Retrieves the carbon breakdown for the day given starting from midnight and with a fixed hourly granularity.
    public func dailyDataUpTo(_ last: Date) -> CarbonBreakdown {
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

    /// Retrieves the carbon breakdown up until the day given and for a fixed number of days.
    public func weeklyDataUpTo(_ last: Date) -> CarbonBreakdown {
        // start from the first day shown at midnight
        let numDaysAgo = Double((WEEKDAYS_SHOWN - 1))
        var dates = [Date.setToSpecificHour(date:
                     last.addingTimeInterval(-numDaysAgo * DAY_IN_SECONDS), hour: "00:00:00")!]
        var labels = [String(Date.getDayName(dates[0]).prefix(3))]
        
        for i in stride(from: 0, to: WEEKDAYS_SHOWN-1, by: 1) {
            dates.append(dates[i].addingTimeInterval(DAY_IN_SECONDS))
            labels.append(String(Date.getDayName(dates[i+1]).prefix(3)))
        }
        dates.append(last)
        labels.append(String(Date.getDayName(last).prefix(3)))
        return breakdownFromDateRanges(rangesBoundaries: dates, withLabels: labels)
    }

    /// Retrieves the carbon breakdown up until the day given and for a fixed number of months.
    public func monthlyDataUpTo(_ last: Date) -> CarbonBreakdown {
        // start from the first month shown at midnight
        let monthStart = Date.getStartOfMonth(fromDate: last)
        let start = Date.addMonths(date: monthStart, numMonthsToAdd: -(MONTHS_SHOWN - 1))
        
        var dates = [start]
        var labels = [String(Date.getMonthName(dates[0]).prefix(3))]
        for i in stride(from: 0, to: MONTHS_SHOWN-1, by: 1) {
            dates.append(Date.addMonths(date: dates[i], numMonthsToAdd: 1))
            labels.append(String(Date.getMonthName(dates[i+1]).prefix(3)))
        }
        dates.append(last)
        labels.append(String(Date.getMonthName(last).prefix(3)))
        
        return breakdownFromDateRanges(rangesBoundaries: dates, withLabels: labels)
    }

    /// Retrieves the carbon breakdown up until the day given and for a fixed number of years.
    public func yearlyDataUpTo(_ last: Date) -> CarbonBreakdown {
        // start from the first year shown on the 1st of Jan at midnight
        let monthStart = Date.getStartOfMonth(fromDate: last)
        let firstOfJan = Date.setToSpecificMonth(date: monthStart, month: 1)!
        let start = Date.addMonths(date: firstOfJan, numMonthsToAdd: -(YEARS_SHOWN - 1) * 12)
        
        var dates = [start]
        var labels = [Date.getYearAsString(dates[0])]
        for i in stride(from: 0, to: YEARS_SHOWN-1, by: 1) {
            dates.append(Date.addMonths(date: dates[i], numMonthsToAdd: 12))
            labels.append(Date.getYearAsString(dates[i+1]))
        }
        dates.append(last)
        labels.append(String(Date.getYearAsString(last).prefix(3)))
        
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
                
                if motion.isPolluting() {
                    if dataTotal.count > i-1 {
                        dataTotal[i-1].data += carbon
                    } else { // not initialised
                        dataTotal.append(LabelledDataPoint(data: carbon, label: withLabels[i-1]))
                    }
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
