import Foundation

// cached date formatter as suggested in
//https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html#//apple_ref/doc/uid/TP40002369-SW10
let dateFormatter = DateFormatter()

extension Date {
    /// Returns the full day name of the given date in UK english.
    public static func getDayName(_ date: Date) -> String{
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en-UK")
        return dateFormatter.string(from: date)
    }
    
    /// Returns the full month name of the given date in UK english.
    public static func getMonthName(_ date: Date) -> String{
        dateFormatter.dateFormat = "MMMM"
        dateFormatter.locale = Locale(identifier: "en-UK")
        return dateFormatter.string(from: date)
    }
    
    /** Returns the resulting of adding a specified number of months to the given date.
    - Parameter date: the starting date.
    - Parameter numMonthsToAdd: number of months to add. If negative, the resulting date is antecedent.
    */
    public static func addMonths(date:Date, numMonthsToAdd: Int) -> Date {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        var addendum = DateComponents()
        addendum.month = numMonthsToAdd
        return calendar.date(byAdding: addendum, to: date)!
    }
    
    /// Returns the first of the month of the specified date, set to midnight.
    public static func getStartOfMonth(fromDate: Date) -> Date {
        return setToSpecificHour(date: setToSpecificDay(date: fromDate, day: 1)!, hour: "00:00:00")!
    }
    
    /// Converts a date to a string in the format yyyy-MM-dd.
    public static func toInternationalString(_ date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    /** Returns the date given but set to the hour provided.
    - Parameter date: date to modify.
    - Parameter hour: hour to set to date to in the format HH:mm:ss.
    - Returns: the date given set to the hour provided, or nil if the action failed.
    */
    public static func setToSpecificHour(date: Date, hour: String) -> Date? {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en-UK")
        let formattedStr = dateFormatter.string(from: date) + " " + hour + " +0000"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        return dateFormatter.date(from: formattedStr)
    }
    
    /** Returns the date given but set to the day provided.
    - Parameter date: date to modify.
    - Parameter day: day the returned date will be set to.
    - Returns: the date given set to the day provided, or nil if the action failed.
    */
    public static func setToSpecificDay(date: Date, day: Int) -> Date? {
        dateFormatter.locale = Locale(identifier: "en-UK")
        
        dateFormatter.dateFormat = "yyyy-MM"
        let yearMonth = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "HH:mm:ss ZZZ"
        let hour = dateFormatter.string(from: date)
        
        let dayStr = (day > 9) ? String(day) : "0" + String(day)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let formattedStr = yearMonth + "-" + dayStr + " " + hour
        return dateFormatter.date(from: formattedStr)
    }
    
    /** Returns the date given but set to the month provided.
    - Parameter date: date to modify.
    - Parameter month: month the returned date will be set to.
    - Returns: the date given set to the month provided, or nil if the action failed.
    */
    public static func setToSpecificMonth(date: Date, month: Int) -> Date? {
        dateFormatter.locale = Locale(identifier: "en-UK")
        
        dateFormatter.dateFormat = "dd HH:mm:ss ZZZ"
        let dayHour = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: date)
        let monthStr = (month > 9) ? String(month) : "0" + String(month)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let formattedStr = year + "-" + monthStr + "-" + dayHour
        return dateFormatter.date(from: formattedStr)
    }
    
    /** Returns the date given but set to the year provided.
    - Parameter date: date to modify.
    - Parameter day: year the date will be set to.
    - Returns: the date given set to the year provided, or nil if the action failed.
    */
    public static func setToSpecificYear(date: Date, year: Int) -> Date? {
        dateFormatter.locale = Locale(identifier: "en-UK")
        
        dateFormatter.dateFormat = "MM-dd HH:mm:ss ZZZ"
        let monthDayHour = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let formattedStr = String(year) + "-" + monthDayHour
        return dateFormatter.date(from: formattedStr)
    }
    
    /// Returns the year of the specified date as a string. Year format is yyyy.
    public static func getYearAsString(_ date: Date) -> String {
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
}
