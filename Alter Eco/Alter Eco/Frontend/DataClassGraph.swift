import Foundation

//Data structure for the keys in dictionary (declared in GraphView) used to pull the values into the bar charts. The picker values are used to index these variables.
enum DataParts: Int, CaseIterable, Hashable, Identifiable {
    case day=0
    case week
    case month
    case year
    case dayall
    case daycar
    case daywalk
    case daytrain
    case dayplane
    case weekall
    case weekcar
    case weekwalk
    case weektrain
    case weekplane
    case monthall
    case monthcar
    case monthwalk
    case monthtrain
    case monthplane
    case yearall
    case yearcar
    case yearwalk
    case yeartrain
    case yearplane
    
    var name: String {
        return "\(self)".capitalized
    }
    var id: DataParts {self}
}

//Data type used in the dictionary and the x-labels in the bar graph (when the string function is called)
enum DaySpecifics: CaseIterable, Hashable, Identifiable {
    case zerohour
    case twohour
    case threehour
    case fourhour
    case fivehour
    case sixhour
    case sevenhour
    case eighthour
    case ninehour
    case tenhour
    case elevenhour
    case twelvehour
    case thirteenhour
    case fourteenhour
    case fifteenhour
    case sixteenhour
    case seventeenhour
    case eighteenhour
    case nineteenhour
    case twentyhour
    case twentyonehour
    case twentytwohour
    case twentythreehour
    case twentyfourhour
    
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    case january
    case febuary
    case march
    case april
    case may
    case june
    case july
    case august
    case september
    case october
    case november
    case december
    
    case minusSixYearsEnum
    case minusFiveYearsEnum
    case minusFourYearsEnum
    case minusThreeYearsEnum
    case minusTwoYearsEnum
    case lastYearEnum
    case thisYearEnum

       
    //member function to convert value to a string
    var shortName: String {
        
        if (self==DaySpecifics.minusSixYearsEnum)
        { return yearsStrings[0]}
        if (self==DaySpecifics.minusFiveYearsEnum)
        { return yearsStrings[1]}
        if (self==DaySpecifics.minusFourYearsEnum)
        { return yearsStrings[2]}
        if (self==DaySpecifics.minusThreeYearsEnum)
        { return yearsStrings[3]}
        if (self==DaySpecifics.minusTwoYearsEnum)
        { return yearsStrings[4]}
        if (self==DaySpecifics.lastYearEnum)
        { return yearsStrings[5]}
        if (self==DaySpecifics.thisYearEnum)
        { return yearsStrings[6]}
        if (self==DaySpecifics.zerohour)
        { return "00"}
        if (self==DaySpecifics.twohour)
        { return "02"}
        if (self==DaySpecifics.fourhour)
        { return "04"}
        if (self==DaySpecifics.sixhour)
        { return "06"}
        if (self==DaySpecifics.eighthour)
        { return "08"}
        if (self==DaySpecifics.tenhour)
        { return "10"}
        if (self==DaySpecifics.twelvehour)
        { return "12"}
        if (self==DaySpecifics.fourteenhour)
        { return "14"}
        if (self==DaySpecifics.sixteenhour)
        { return "16"}
        if (self==DaySpecifics.eighteenhour)
        { return "18"}
        if (self==DaySpecifics.twentyhour)
        { return "20"}
        if (self==DaySpecifics.twentytwohour)
        { return "22"}
        if (self==DaySpecifics.twentyfourhour)
        { return "24"}
        else
        {return String("\(self)".prefix(2)).capitalized}
    }
    var id: DaySpecifics {self}
    
}
