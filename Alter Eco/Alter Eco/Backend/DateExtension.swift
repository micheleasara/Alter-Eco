import Foundation

extension Date {
    public static func getDayNameFromDate(_ date: Date) -> String{
        let dateFormatter = DateFormatter()
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    public static func monthNameToMonthNumber(month: String) -> String {
        switch month {
            case "January":
            return "01"
            case "February":
            return "02"
            case "March":
            return "03"
            case "April":
            return "04"
            case "May":
            return "05"
            case "June":
            return "06"
            case "July":
            return "07"
            case "August":
            return "08"
            case "September":
            return "09"
            case "October":
            return "10"
            case "November":
            return "11"
            case "December":
            return "12"
            default:
            return "00"
        }
    }
    
    public static func dayNameToOrderInWeek(_ day: String) -> Int {
        switch day {
            case "Sunday":
                return 1
            case "Monday":
                return 2
            case "Tuesday":
                return 3
            case "Wednesday":
                return 4
            case "Thursday":
                return 5
            case "Friday":
                return 6
            case "Saturday":
                return 7
            default:
                return 0
        }
    }

    public static func getDateFromWeekdayName(weekDayToDisplay: String) -> Date? {
        var dateToView = Date()
        let dayToday = Calendar(identifier: .gregorian).component(.weekday, from: Date())
        let dayDifference = dayToday - dayNameToOrderInWeek(weekDayToDisplay)
        dateToView = Calendar(identifier: .gregorian).date(byAdding: .day, value: dayDifference, to: dateToView)!
        return setDateToSpecificHour(date: dateToView, hour: "00:00:00")
    }
    
    public static func setDateToSpecificHour(date: Date, hour: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en-UK")
        var todayDate = dateFormatter.string(from: date)
        todayDate = todayDate + " " + hour + " +0000"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        if let today = dateFormatter.date(from: todayDate) {
            return today
        }
        return nil
    }
    
    public static func inSameDay(date1:Date, date2:Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.dateComponents([.day, .month, .year], from: date1) == calendar.dateComponents([.day, .month, .year], from: date2)
    }
}
