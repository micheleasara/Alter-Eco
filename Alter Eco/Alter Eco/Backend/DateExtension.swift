import Foundation

// cached date formatter as suggested in
//https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html#//apple_ref/doc/uid/TP40002369-SW10
let dateFormatter = DateFormatter()

extension Date {
    public static func getDayNameFromDate(_ date: Date) -> String{
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en-UK")
        return dateFormatter.string(from: date)
    }
    
    public static func getEndDayOfMonth(date: Date) -> Date {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        let components = calendar.components([.year, .month], from: date)
        let startOfMonth = calendar.date(from: components)!
        var addendum = DateComponents()
        addendum.month = 1
        addendum.day = -1
        return calendar.date(byAdding: addendum, to: startOfMonth)!
    }

    public static func dateToInternationalString(_ date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    public static func monthNameToFirstOfMonth(month: String) -> Date? {
        dateFormatter.dateFormat = "LLLL"
        dateFormatter.locale = Locale(identifier: "en-UK")
        
        var date = dateFormatter.date(from: month)
        if date != nil {
            let currentYear = Calendar(identifier: .gregorian).component(.year, from: Date())
            date = setDateToSpecificYear(date: date!, year: currentYear)
            if date != nil {
                date = setDateToSpecificDay(date: date!, day: 1)
                if date != nil {
                    date = setDateToSpecificHour(date: date!, hour: "00:00:00")
                    return date
                }
            }
        }
        return nil
    }
    
    public static func dayNameToOrderInWeek(_ day: String) -> Int? {
        let orderOfTheWeek = ["sunday" : 1, "monday" : 2, "tuesday" : 3, "wednesday" : 4, "thursday" : 5, "friday" : 6, "saturday" : 7]
        return orderOfTheWeek[day.lowercased()]
    }

    public static func getDateFromWeekdayName(weekDayToDisplay: String) -> Date? {
        var dateToView = Date()
        let dayToday = Calendar(identifier: .gregorian).component(.weekday, from: Date())
        let dayDifference = dayToday - dayNameToOrderInWeek(weekDayToDisplay)!
        dateToView = Calendar(identifier: .gregorian).date(byAdding: .day, value: dayDifference, to: dateToView)!
        return setDateToSpecificHour(date: dateToView, hour: "00:00:00")
    }
    
    public static func setDateToSpecificHour(date: Date, hour: String) -> Date? {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en-UK")
        let formattedStr = dateFormatter.string(from: date) + " " + hour + " +0000"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        if let today = dateFormatter.date(from: formattedStr) {
            return today
        }
        return nil
    }
    
    public static func setDateToSpecificDay(date: Date, day: Int) -> Date? {
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
    
    public static func setDateToSpecificYear(date: Date, year: Int) -> Date? {
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
    
    public static func inSameDay(date1:Date, date2:Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.dateComponents([.day, .month, .year], from: date1) == calendar.dateComponents([.day, .month, .year], from: date2)
    }
    
    public static func toYearString(years: [Date]) -> [String] {
        
        dateFormatter.dateFormat = "yyyy"
        
        var yearsStrings = [String] ()
        
        for date in years {           
            yearsStrings.append(dateFormatter.string(from: date))
        }
        
        return yearsStrings
    }
}
