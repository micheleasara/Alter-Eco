import Foundation

/// Provides thread-safe date formatting according to the invariant "en_US_POSIX" locale and with GMT timezone.
public class FixedDateFormatter {
    /// Singleton instance
    private static let INSTANCE = FixedDateFormatter()
    /// Queue used to run formatting requests thread safely.
    private let queue = DispatchQueue(label: "com.altereco.fixeddateformatting")
    // cached date formatter as suggested in
    //https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html#//apple_ref/doc/uid/TP40002369-SW10
    private var formatter = DateFormatter()
    
    /// Returns the singleton instance.
    public static func getInstance() -> FixedDateFormatter {
        return INSTANCE
    }
    
    /// Returns a string representation of the given date according to the format provided.
    public func string(date: Date, format: String) -> String {
        var formatted: String = ""
        queue.sync {
            formatter.dateFormat = format
            formatted = formatter.string(from: date)
        }
        return formatted
    }
    
    /// Returns a date representation of the given string according to the format provided. Returns nil in case of failure.
    public func date(from: String, format: String) -> Date? {
        var date: Date?
        queue.sync {
            formatter.dateFormat = format
            date = formatter.date(from: from)
        }
        return date
    }
    
    private init() {
        // ensure timezone is fixed to GMT
        formatter.timeZone = TimeZone(secondsFromGMT: 0)!
        // invariant locale is "en_US_POSIX", see
        // https://developer.apple.com/library/archive/qa/qa1480/_index.html
        formatter.locale = Locale(identifier: "en_US_POSIX")
    }
}


extension Date {
    /// Returns the full day name in english.
    public func getDayName() -> String{
        return FixedDateFormatter.getInstance().string(date: self, format: "EEEE")
    }
    
    /// Returns the full month name in english.
    public func getMonthName() -> String {
        return FixedDateFormatter.getInstance().string(date: self, format: "MMMM")
    }
    
    /** Returns the resulting of adding a specified number of months.
    - Parameter numMonthsToAdd: number of months to add. If negative, the resulting date is antecedent.
    */
    public func addMonths(numMonthsToAdd: Int) -> Date {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        var addendum = DateComponents()
        addendum.month = numMonthsToAdd
        return calendar.date(byAdding: addendum, to: self)!
    }
    
    /// Returns the first of the month set to midnight.
    public func getStartOfMonth() -> Date? {
        return self.setToSpecificDay(day: 1)?.setToSpecificHour(hour: "00:00:00")
    }
    
    /// Converts a date to a string in the format yyyy-MM-dd.
    public func toInternationalString() -> String {
        return FixedDateFormatter.getInstance().string(date: self, format: "yyyy-MM-dd")
    }
    
    /** Returns the date set to the hour provided.
    - Parameter hour: hour to set to date to in the format HH:mm:ss.
    - Returns: the date set to the hour provided, or nil if the action failed.
    */
    public func setToSpecificHour(hour: String) -> Date? {
        let formatter = FixedDateFormatter.getInstance()
        let yearMonthDay = formatter.string(date: self, format: "yyyy-MM-dd")
        let formattedStr = yearMonthDay + " " + hour + " +0000"
        return formatter.date(from: formattedStr, format: "yyyy-MM-dd HH:mm:ss ZZZ")
    }
    
    /** Returns the date set to the day provided.
    - Parameter day: day the returned date will be set to.
    - Returns: the date set to the day provided, or nil if the action failed.
    */
    public func setToSpecificDay(day: Int) -> Date? {
        let formatter = FixedDateFormatter.getInstance()
        let yearMonth = formatter.string(date: self, format: "yyyy-MM")
        let hour = formatter.string(date: self, format: "HH:mm:ss ZZZ")
        let dayStr = (day > 9) ? String(day) : "0" + String(day)
        
        let formattedStr = yearMonth + "-" + dayStr + " " + hour
        return formatter.date(from: formattedStr, format: "yyyy-MM-dd HH:mm:ss ZZZ")
    }
    
    /** Returns the date set to the month provided.
    - Parameter month: month the returned date will be set to.
    - Returns: the date set to the month provided, or nil if the action failed.
    */
    public func setToSpecificMonth(month: Int) -> Date? {
        let formatter = FixedDateFormatter.getInstance()
        let dayHour = formatter.string(date: self, format: "dd HH:mm:ss ZZZ")
        let year = formatter.string(date: self, format: "yyyy")
        let monthStr = (month > 9) ? String(month) : "0" + String(month)

        let formattedStr = year + "-" + monthStr + "-" + dayHour
        return formatter.date(from: formattedStr, format: "yyyy-MM-dd HH:mm:ss ZZZ")
    }
    
    /// Returns the year as a string. Year format is yyyy.
    public func getYearAsString() -> String {
        return FixedDateFormatter.getInstance().string(date: self, format: "yyyy")
    }

    /// Converts date from GMT to local time.
    public func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    /// Converts date from local time to GMT.
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}
