import Foundation

// cached date formatter as suggested in
//https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html#//apple_ref/doc/uid/TP40002369-SW10
let dateFormatter = DateFormatter()

extension Date {
    /// Returns the day name of the given date in UK english.
    public static func getDayName(_ date: Date) -> String{
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en-UK")
        return dateFormatter.string(from: date)
    }
    
    /// Returns the date of the last of the month from the given date.
    public static func getEndDayOfMonth(date: Date) -> Date {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        let components = calendar.components([.year, .month], from: date)
        let startOfMonth = calendar.date(from: components)!
        var addendum = DateComponents()
        addendum.month = 1
        addendum.day = -1
        return calendar.date(byAdding: addendum, to: startOfMonth)!
    }

    /// Converts a date to a string in the format yyyy-MM-dd.
    public static func toInternationalString(_ date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    /**
     Returns a date object representing the first of the month given.
     - Parameter month: month's full name in UK english.
     */
    public static func monthNameToFirstOfMonth(month: String) -> Date? {
        dateFormatter.dateFormat = "LLLL"
        dateFormatter.locale = Locale(identifier: "en-UK")
        
        var date = dateFormatter.date(from: month)
        if date != nil {
            let currentYear = Calendar(identifier: .gregorian).component(.year, from: Date())
            date = setToSpecificYear(date: date!, year: currentYear)
            if date != nil {
                date = setToSpecificDay(date: date!, day: 1)
                if date != nil {
                    date = setToSpecificHour(date: date!, hour: "00:00:00")
                    return date
                }
            }
        }
        return nil
    }
    
    /** Converts the name of a day of the week to an integer representing its position in the list from Sunday to Saturday.
    - Parameter day: full day's name in UK english.
    - Returns: the position of the day or nil if it is not recognized.
    */
    public static func dayNameToOrderInWeek(_ day: String) -> Int? {
        let orderOfTheWeek = ["sunday" : 1, "monday" : 2, "tuesday" : 3, "wednesday" : 4, "thursday" : 5, "friday" : 6, "saturday" : 7]
        return orderOfTheWeek[day.lowercased()]
    }
    
    /** Returns the name of a day to the corresponding date in the current week.
    - Parameter weekDayToDisplay: full day's name in UK english.
    - Returns: the date of the day or nil if it is not recognized.
    */
    public static func fromWeekdayName(weekDayToDisplay: String) -> Date? {
        var dateToView = Date()
        let dayToday = getDayName(dateToView)
        let dayDifference = dayNameToOrderInWeek(weekDayToDisplay)! - dayNameToOrderInWeek(dayToday)!
        dateToView = Calendar(identifier: .gregorian).date(byAdding: .day, value: dayDifference, to: dateToView)!
        return setToSpecificHour(date: dateToView, hour: "00:00:00")
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
        if let today = dateFormatter.date(from: formattedStr) {
            return today
        }
        return nil
    }
    
    /** Returns the date given but set to the day provided.
    - Parameter date: date to modify.
    - Parameter day: day to set to date to.
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
        if let formattedDate = dateFormatter.date(from: formattedStr) {
            return formattedDate
        }
        return nil
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
        if let formattedDate = dateFormatter.date(from: formattedStr) {
            return formattedDate
        }
        return nil
    }
    
    /// Returns whether the two dates are in the same day.
    public static func inSameDay(date1:Date, date2:Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.dateComponents([.day, .month, .year], from: date1) == calendar.dateComponents([.day, .month, .year], from: date2)
    }
    
    /// Converts an array of dates into an array of string representations of their years. Year format is yyyy.
    public static func toYearString(years: [Date]) -> [String] {
        dateFormatter.dateFormat = "yyyy"
        
        var yearsStrings = [String] ()
        for date in years {           
            yearsStrings.append(dateFormatter.string(from: date))
        }
        
        return yearsStrings
    }
}
