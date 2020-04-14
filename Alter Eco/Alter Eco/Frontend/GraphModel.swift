import Foundation
import SwiftUI
let AV_UK_DAILYCARBON: Double = 2200

let thisYear = Date()
let nextYear = Calendar.current.date(byAdding: .year, value: 1, to: thisYear)
let plusTwoYears = Calendar.current.date(byAdding: .year, value: 2, to: thisYear)
let plusThreeYears = Calendar.current.date(byAdding: .year, value: 3, to: thisYear)
let lastYear = Calendar.current.date(byAdding: .year, value: -1, to: thisYear)
let minusTwoYears = Calendar.current.date(byAdding: .year, value: -2, to: thisYear)
let minusThreeYears = Calendar.current.date(byAdding: .year, value: -3, to: thisYear)

func findMaxValue(value: Int) -> Double {
    
    var maxVal: Double
    switch (value) {
    case 0:
    maxVal = normaliseHourlyAll()
    case 1:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)
    case 2:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)
    case 3:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)
    case 4:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)
    case 5:
    maxVal = normaliseWeeklyAll()
    case 6:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar)
    case 7:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk)
    case 8:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain)
    case 9:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane)
    case 10:
    maxVal = normaliseMonthlyAll()
    case 11:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)
    case 12:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)
    case 13:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)
    case 14:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)
    case 15:
    maxVal = normaliseYearlyAll()
    case 16:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)
    case 17:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk)
    case 18:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain)
    case 19:
    maxVal = normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane)

    default:
    maxVal = 70.0
    }
    //Due to divide by zero errors in the normalisation equations, if there is not a carbon value, then the normalised version is set to divide by '1' instead of '0'. This is corrected for here.
    if (maxVal==1)
    {
    maxVal=0
    }
    
    
    return maxVal
}

func findCorrectUnits(currentMax: Double, value: Int) -> (Double, String, String, String) {
    var carbonUnit: String = "Carbon kgs"
    var decimalPlaces: String = "%.1f"
    var savedOrEmitted: String
    var maxVal: Double = currentMax
    
    //Units change depending on whether the total amount of carbon in Kgs is over or under 1000 (helps ensure the y-axis labels fit on the screen and adds clarity
    
    // Keeps kg if between 1-100
    if (currentMax>1 && currentMax<=100){
        maxVal=currentMax
        carbonUnit="  Carbon kgs"
        decimalPlaces = "%.0f"
    }
    // Get tonnes if more 100 kg
    if (currentMax>100) {
        maxVal=currentMax/1000
        carbonUnit="  Carbon Tonnes"
        decimalPlaces = "%.0f"
    }
   
    if ((value==2)||(value==7)||(value==12)||(value==17)) {
        savedOrEmitted="   Saved"
       }
    else {
        savedOrEmitted="Emitted"
       }
    return (maxVal, carbonUnit, decimalPlaces, savedOrEmitted)
}

func findGraphColour() -> String {
    
    var colour: String = "graphBars"
    
    do {
        if (try DBMS.queryHourlyCarbonAll(hourStart: "00:00:00", hourEnd: "23:59:59") > AV_UK_DAILYCARBON) {
            colour = "redGraphBar"
        }
    } catch {
        print("Unexpected error: \(error).")
    }
    return colour
}

func normaliseData(motionType: MeasuredActivity.MotionType, datapart: DataParts) -> Double {
   
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    let thisYearString = dateFormatter.string(from: thisYear)
    let nextYearString = dateFormatter.string(from: nextYear!)
    let plusTwoYearsString = dateFormatter.string(from: plusTwoYears!)
    let plusThreeYearsString = dateFormatter.string(from: plusThreeYears!)
    let lastYearString = dateFormatter.string(from: lastYear!)
    let minusTwoYearsString = dateFormatter.string(from: minusTwoYears!)
    let minusThreeYearsString = dateFormatter.string(from: minusThreeYears!)
 
    var max_data=0.0
    do {
        switch (datapart) {
            case .daycar,.dayplane,.daytrain, .daywalk:
                
                max_data = max(try DBMS.queryHourlyCarbon(motionType: motionType,hourStart: "00:00:00", hourEnd: "02:00:00"),
                               try DBMS.queryHourlyCarbon(motionType: motionType,hourStart: "02:00:00", hourEnd: "04:00:00"),
                               try DBMS.queryHourlyCarbon(motionType: motionType,hourStart: "04:00:00", hourEnd: "06:00:00"),
                               try DBMS.queryHourlyCarbon(motionType: motionType,hourStart: "06:00:00", hourEnd: "08:00:00"),
                               try DBMS.queryHourlyCarbon(motionType: motionType,hourStart: "08:00:00", hourEnd: "10:00:00"),
                               try DBMS.queryHourlyCarbon(motionType: motionType,hourStart: "10:00:00", hourEnd: "12:00:00"),
                               try DBMS.queryHourlyCarbon(motionType: motionType,hourStart: "12:00:00", hourEnd: "14:00:00"),
                               try DBMS.queryHourlyCarbon(motionType: motionType,hourStart: "14:00:00", hourEnd: "16:00:00"),
                               try DBMS.queryHourlyCarbon(motionType: motionType,hourStart: "16:00:00", hourEnd: "18:00:00"),
                               try DBMS.queryHourlyCarbon(motionType: motionType,hourStart: "18:00:00", hourEnd: "20:00:00"),
                               try DBMS.queryHourlyCarbon(motionType: motionType,hourStart: "20:00:00", hourEnd: "22:00:00"),
                               try DBMS.queryHourlyCarbon(motionType: motionType,hourStart: "22:00:00", hourEnd: "23:59:59"))
                
            case .weekcar,.weekplane,.weektrain, .weekwalk:
                
                max_data = max(try DBMS.queryDailyCarbon(motionType: motionType, weekDayToDisplay: "Sunday"),
                               try DBMS.queryDailyCarbon(motionType: motionType,  weekDayToDisplay: "Monday"),
                               try DBMS.queryDailyCarbon(motionType: motionType,  weekDayToDisplay: "Tuesday"),
                               try DBMS.queryDailyCarbon(motionType: motionType,  weekDayToDisplay: "Wednesday"),
                               try DBMS.queryDailyCarbon(motionType: motionType,  weekDayToDisplay: "Thursday"),
                               try DBMS.queryDailyCarbon(motionType: motionType,  weekDayToDisplay: "Friday"),
                               try DBMS.queryDailyCarbon(motionType: motionType, weekDayToDisplay: "Saturday"))
                
            case .monthcar,.monthplane,.monthtrain, .monthwalk:
                
                max_data = max(try DBMS.queryMonthlyCarbon(motionType:motionType, month: "January"),
                               try DBMS.queryMonthlyCarbon(motionType:motionType, month: "February"),
                               try DBMS.queryMonthlyCarbon(motionType:motionType, month: "March"),
                               try DBMS.queryMonthlyCarbon(motionType:motionType, month: "April"),
                               try DBMS.queryMonthlyCarbon(motionType:motionType, month: "May"),
                               try DBMS.queryMonthlyCarbon(motionType:motionType, month: "June"),
                               try DBMS.queryMonthlyCarbon(motionType:motionType, month: "July"),
                               try DBMS.queryMonthlyCarbon(motionType:motionType, month: "August"),
                               try DBMS.queryMonthlyCarbon(motionType:motionType, month: "September"),
                               try DBMS.queryMonthlyCarbon(motionType:motionType, month: "October"),
                               try DBMS.queryMonthlyCarbon(motionType:motionType, month: "November"),
                               try DBMS.queryMonthlyCarbon(motionType:motionType, month: "December"))
            
            case .yearcar,.yearplane,.yeartrain, .yearwalk:
                
                max_data = max(try DBMS.queryYearlyCarbon(motionType: motionType, year: minusThreeYearsString),
                               try DBMS.queryYearlyCarbon(motionType: motionType, year: minusTwoYearsString),
                               try DBMS.queryYearlyCarbon(motionType: motionType, year: lastYearString),
                               try DBMS.queryYearlyCarbon(motionType: motionType, year: thisYearString),
                               try DBMS.queryYearlyCarbon(motionType: motionType, year: nextYearString),
                               try DBMS.queryYearlyCarbon(motionType: motionType, year: plusTwoYearsString),
                               try DBMS.queryYearlyCarbon(motionType: motionType, year: plusThreeYearsString))
            default:
                max_data = 1.0
            }
    } catch {
        print("Unexpected error: \(error).")
    }
    //prevent divide by zero error
    if (max_data == 0.0) {
        max_data = 1.0
    }
    return max_data
}

func normaliseHourlyAll() -> Double {
    
    var max_data : Double = 0
    do {
        max_data = max(try DBMS.queryHourlyCarbonAll(hourStart: "00:00:00", hourEnd: "02:00:00"),try DBMS.queryHourlyCarbonAll(hourStart: "02:00:00", hourEnd: "04:00:00"), try DBMS.queryHourlyCarbonAll(hourStart: "04:00:00", hourEnd: "06:00:00"),try DBMS.queryHourlyCarbonAll(hourStart: "06:00:00", hourEnd: "08:00:00"), try DBMS.queryHourlyCarbonAll(hourStart: "08:00:00", hourEnd: "10:00:00"),try DBMS.queryHourlyCarbonAll(hourStart: "10:00:00", hourEnd: "12:00:00"),try DBMS.queryHourlyCarbonAll(hourStart: "12:00:00", hourEnd: "14:00:00"),try DBMS.queryHourlyCarbonAll(hourStart: "14:00:00", hourEnd: "16:00:00"), try DBMS.queryHourlyCarbonAll(hourStart: "16:00:00", hourEnd: "18:00:00"), try DBMS.queryHourlyCarbonAll(hourStart: "18:00:00", hourEnd: "20:00:00"), try DBMS.queryHourlyCarbonAll(hourStart: "20:00:00", hourEnd: "22:00:00"),try DBMS.queryHourlyCarbonAll(hourStart: "22:00:00", hourEnd: "23:59:59"))
    } catch {
        print("Unexpected error: \(error).")
    }
    //prevent divide by zero error
    if (max_data==0)
    {
        max_data=1.0
    }
    
  return max_data
}

func normaliseWeeklyAll() -> Double {
    var max_data : Double = 0
    do {
        max_data = max(try DBMS.queryDailyCarbonAll(weekDayToDisplay: "Sunday"),
        try DBMS.queryDailyCarbonAll( weekDayToDisplay: "Monday"),
        try DBMS.queryDailyCarbonAll(weekDayToDisplay: "Tuesday"),
        try DBMS.queryDailyCarbonAll(weekDayToDisplay: "Wednesday"),
        try DBMS.queryDailyCarbonAll(weekDayToDisplay: "Thursday"),
        try DBMS.queryDailyCarbonAll(weekDayToDisplay: "Friday"),
        try DBMS.queryDailyCarbonAll(weekDayToDisplay: "Saturday"))
        
    } catch {
        print("Unexpected error: \(error).")
    }
    //prevent divide by zero error
    if (max_data==0)
    {
        max_data=1.0
    }
  return max_data
    
}

func normaliseMonthlyAll() -> Double {
    var max_data : Double = 0
    do {
    max_data = max(try DBMS.queryMonthlyCarbonAll(month: "January"),try DBMS.queryMonthlyCarbonAll(month: "February"),try DBMS.queryMonthlyCarbonAll(month: "March"),try DBMS.queryMonthlyCarbonAll(month: "April"), try DBMS.queryMonthlyCarbonAll(month: "May"),try DBMS.queryMonthlyCarbonAll(month: "June"),try DBMS.queryMonthlyCarbonAll(month: "July"), try DBMS.queryMonthlyCarbonAll(month: "August"),try DBMS.queryMonthlyCarbonAll(month:"September"), try DBMS.queryMonthlyCarbonAll(month: "October"), try DBMS.queryMonthlyCarbonAll(month: "November"),try DBMS.queryMonthlyCarbonAll(month: "December"))
    
    } catch {
        print("Unexpected error: \(error).")
    }
    //prevent divide by zero error
    if (max_data==0)
    {
        max_data=1.0
    }
    
  return max_data
}

func normaliseYearlyAll() -> Double {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    let thisYearString = dateFormatter.string(from: thisYear)
    let nextYearString = dateFormatter.string(from: nextYear!)
    let plusTwoYearsString = dateFormatter.string(from: plusTwoYears!)
    let plusThreeYearsString = dateFormatter.string(from: plusThreeYears!)
    let lastYearString = dateFormatter.string(from: lastYear!)
    let minusTwoYearsString = dateFormatter.string(from: minusTwoYears!)
    let minusThreeYearsString = dateFormatter.string(from: minusThreeYears!)
    var max_data = 0.0
    do {
        max_data = max(try DBMS.queryYearlyCarbonAll(year: minusThreeYearsString),try DBMS.queryYearlyCarbonAll(year: minusTwoYearsString),try DBMS.queryYearlyCarbonAll(year: lastYearString), try DBMS.queryYearlyCarbonAll(year: thisYearString),try DBMS.queryYearlyCarbonAll(year: nextYearString),try DBMS.queryYearlyCarbonAll(year: plusTwoYearsString),try DBMS.queryYearlyCarbonAll(year: plusThreeYearsString))
    } catch {
        print("Unexpected error: \(error).")
    }
    
    //prevent divide by zero error
    if (max_data==0)
    {
        max_data=1.0
    }
    
    return max_data
}

//A dictionary data structure for the bar chart.
//Access by the data type 'DataParts' declared in the file DataClassGraph. This value is determined by the picker sum (e.g. if day + car view is selected the picker sum will be '1' and therefore DataParts.daycar (position 1 in the dictionary) will be displayed).

var data: [(dayPart: DataParts, carbonByDate: [(day:DaySpecifics, carbon:Double)])] = fetchDataGraph()

func updateDataGraph() {
    data = fetchDataGraph()
}

func fetchDataGraph() -> [(dayPart: DataParts, carbonByDate: [(day:DaySpecifics, carbon:Double)])] {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    let thisYearString = dateFormatter.string(from: thisYear)
    let nextYearString = dateFormatter.string(from: nextYear!)
    let plusTwoYearsString = dateFormatter.string(from: plusTwoYears!)
    let plusThreeYearsString = dateFormatter.string(from: plusThreeYears!)
    let lastYearString = dateFormatter.string(from: lastYear!)
    let minusTwoYearsString = dateFormatter.string(from: minusTwoYears!)
    let minusThreeYearsString = dateFormatter.string(from: minusThreeYears!)
    
    
    return [
                (//Access dictionary via this key
                    DataParts.dayall,
                   [//The nested dictionary holds the individual values e.g. for day this is the normalised hourly time points
                      (DaySpecifics.twohour, try! DBMS.queryHourlyCarbonAll(hourStart: "00:00:00", hourEnd: "02:00:00")/normaliseHourlyAll()),
                        (DaySpecifics.fourhour, try! DBMS.queryHourlyCarbonAll(hourStart: "02:00:00", hourEnd: "04:00:00")/normaliseHourlyAll()),
                        (DaySpecifics.sixhour, try! DBMS.queryHourlyCarbonAll(hourStart: "04:00:00", hourEnd: "06:00:00")/normaliseHourlyAll()),
                        (DaySpecifics.eighthour, try! DBMS.queryHourlyCarbonAll(hourStart: "06:00:00", hourEnd: "08:00:00")/normaliseHourlyAll()),
                        (DaySpecifics.tenhour, try! DBMS.queryHourlyCarbonAll(hourStart: "08:00:00", hourEnd: "10:00:00")/normaliseHourlyAll()),
                        (DaySpecifics.twelvehour, try! DBMS.queryHourlyCarbonAll(hourStart: "10:00:00", hourEnd: "12:00:00")/normaliseHourlyAll()),
                        (DaySpecifics.fourteenhour, try! DBMS.queryHourlyCarbonAll(hourStart: "12:00:00", hourEnd: "14:00:00")/normaliseHourlyAll()),
                        (DaySpecifics.sixteenhour, try! DBMS.queryHourlyCarbonAll(hourStart: "14:00:00", hourEnd: "16:00:00")/normaliseHourlyAll()),
                        (DaySpecifics.eighteenhour, try! DBMS.queryHourlyCarbonAll(hourStart: "16:00:00", hourEnd: "18:00:00")/normaliseHourlyAll()),
                        (DaySpecifics.twentyhour, try! DBMS.queryHourlyCarbonAll(hourStart: "18:00:00", hourEnd: "20:00:00")/normaliseHourlyAll()),
                        (DaySpecifics.twentytwohour, try! DBMS.queryHourlyCarbonAll(hourStart: "20:00:00", hourEnd: "22:00:00")/normaliseHourlyAll()),
                        (DaySpecifics.twentyfourhour, try! DBMS.queryHourlyCarbonAll(hourStart: "22:00:00", hourEnd: "23:59:59")/normaliseHourlyAll()),
                    ]
                ),
                (
                  DataParts.daycar,
                  [
                    (DaySpecifics.twohour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "00:00:00", hourEnd: "02:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                      (DaySpecifics.fourhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "02:00:00", hourEnd: "04:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                      (DaySpecifics.sixhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "04:00:00", hourEnd: "06:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                      (DaySpecifics.eighthour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "06:00:00", hourEnd: "08:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                      (DaySpecifics.tenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "08:00:00", hourEnd: "10:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                      (DaySpecifics.twelvehour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "10:00:00", hourEnd:  "12:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                      (DaySpecifics.fourteenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "12:00:00", hourEnd: "14:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                      (DaySpecifics.sixteenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "14:00:00", hourEnd: "16:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                      (DaySpecifics.eighteenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "16:00:00", hourEnd: "18:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                      (DaySpecifics.twentyhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "18:00:00", hourEnd: "20:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                      (DaySpecifics.twentytwohour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "20:00:00", hourEnd: "22:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                      (DaySpecifics.twentyfourhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "22:00:00", hourEnd: "23:59:59")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),

                  ]
                                                  
                      ),
                      (
                          DataParts.daywalk,
                  [
                    (DaySpecifics.twohour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "00:00:00", hourEnd: "02:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                      (DaySpecifics.fourhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "02:00:00", hourEnd: "04:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                      (DaySpecifics.sixhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "04:00:00", hourEnd: "06:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                      (DaySpecifics.eighthour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "06:00:00", hourEnd: "08:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                      (DaySpecifics.tenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "08:00:00", hourEnd: "10:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                      (DaySpecifics.twelvehour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "10:00:00", hourEnd: "12:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                      (DaySpecifics.fourteenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "12:00:00", hourEnd: "14:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                      (DaySpecifics.sixteenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "14:00:00", hourEnd: "16:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                      (DaySpecifics.eighteenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "16:00:00", hourEnd: "18:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                      (DaySpecifics.twentyhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "18:00:00", hourEnd: "20:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                      (DaySpecifics.twentytwohour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "20:00:00", hourEnd: "22:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                      (DaySpecifics.twentyfourhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "22:00:00", hourEnd: "23:59:59")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                  ]
                      ),
                  (
                      DataParts.daytrain,
                  [
                    (DaySpecifics.twohour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "00:00:00", hourEnd: "02:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                      (DaySpecifics.fourhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "02:00:00", hourEnd: "04:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                      (DaySpecifics.sixhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "04:00:00", hourEnd: "06:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                      (DaySpecifics.eighthour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "06:00:00", hourEnd: "08:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                      (DaySpecifics.tenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "08:00:00", hourEnd: "10:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                      (DaySpecifics.twelvehour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "10:00:00", hourEnd: "12:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                      (DaySpecifics.fourteenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "12:00:00", hourEnd: "14:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                      (DaySpecifics.sixteenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "14:00:00", hourEnd: "16:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                      (DaySpecifics.eighteenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "16:00:00", hourEnd: "18:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                      (DaySpecifics.twentyhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "18:00:00", hourEnd: "20:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                      (DaySpecifics.twentytwohour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "20:00:00", hourEnd: "22:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                      (DaySpecifics.twentyfourhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "22:00:00", hourEnd: "23:59:59")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                  ]

                  ),
                  (
                    DataParts.dayplane,
                 [
                    (DaySpecifics.twohour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "00:00:00", hourEnd: "02:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                    (DaySpecifics.fourhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "02:00:00", hourEnd: "04:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                    (DaySpecifics.sixhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "04:00:00", hourEnd: "06:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                    (DaySpecifics.eighthour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "06:00:00", hourEnd: "08:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                    (DaySpecifics.tenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "08:00:00", hourEnd: "10:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                    (DaySpecifics.twelvehour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "10:00:00", hourEnd: "12:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                    (DaySpecifics.fourteenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "12:00:00", hourEnd: "14:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                    (DaySpecifics.sixteenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "14:00:00", hourEnd: "16:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                    (DaySpecifics.eighteenhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "16:00:00", hourEnd: "18:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                    (DaySpecifics.twentyhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "18:00:00", hourEnd: "20:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                    (DaySpecifics.twentytwohour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "20:00:00", hourEnd: "22:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                    (DaySpecifics.twentyfourhour, try! DBMS.queryHourlyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "22:00:00", hourEnd: "23:59:59")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),

                 ]
         ),
                  (
                    DataParts.weekall,
                  [
                      (DaySpecifics.sunday, try! DBMS.queryDailyCarbonAll(weekDayToDisplay: "Sunday")/normaliseWeeklyAll()),
                      (DaySpecifics.monday, try! DBMS.queryDailyCarbonAll(weekDayToDisplay: "Monday")/normaliseWeeklyAll()),
                      (DaySpecifics.tuesday, try! DBMS.queryDailyCarbonAll(weekDayToDisplay: "Tuesday")/normaliseWeeklyAll()),
                      (DaySpecifics.wednesday, try! DBMS.queryDailyCarbonAll(weekDayToDisplay: "Wednesday")/normaliseWeeklyAll()),
                      (DaySpecifics.thursday, try! DBMS.queryDailyCarbonAll(weekDayToDisplay: "Thursday")/normaliseWeeklyAll()),
                      (DaySpecifics.friday, try! DBMS.queryDailyCarbonAll(weekDayToDisplay: "Friday")/normaliseWeeklyAll()),
                      (DaySpecifics.saturday, try! DBMS.queryDailyCarbonAll(weekDayToDisplay: "Saturday")/normaliseWeeklyAll()),
                  ]
                  ),
                  (
                    DataParts.weekcar,
                  [
                    (DaySpecifics.sunday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay: "Sunday")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar)),
                      (DaySpecifics.monday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay: "Monday")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar)),
                      (DaySpecifics.tuesday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay: "Tuesday")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar)),
                      (DaySpecifics.wednesday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay: "Wednesday")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar)),
                      (DaySpecifics.thursday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay: "Thursday")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar)),
                      (DaySpecifics.friday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay: "Friday")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar)),
                      (DaySpecifics.saturday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay: "Saturday")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar))
                  ]
                  ),
                  (
                    DataParts.weekwalk,
                  [
                      (DaySpecifics.sunday,try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, weekDayToDisplay: "Sunday")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk) ),
                      (DaySpecifics.monday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, weekDayToDisplay: "Monday")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk)),
                      (DaySpecifics.tuesday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, weekDayToDisplay: "Tuesday")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk)),
                      (DaySpecifics.wednesday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, weekDayToDisplay: "Wednesday")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk)),
                      (DaySpecifics.thursday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, weekDayToDisplay: "Thursday")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk)),
                      (DaySpecifics.friday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, weekDayToDisplay: "Friday")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk)),
                      (DaySpecifics.saturday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, weekDayToDisplay: "Saturday")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk))
                  ]
                  ),
                  (
                    DataParts.weektrain,
               [
                    (DaySpecifics.sunday,try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay: "Sunday")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain) ),
                    (DaySpecifics.monday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay: "Monday")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain)),
                    (DaySpecifics.tuesday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay: "Tuesday")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain)),
                    (DaySpecifics.wednesday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay: "Wednesday")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain)),
                    (DaySpecifics.thursday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay: "Thursday")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain)),
                    (DaySpecifics.friday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay: "Friday")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain)),
                    (DaySpecifics.saturday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay: "Saturday")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain))
                ]
                ),
                  (DataParts.weekplane,
                  [
                   (DaySpecifics.sunday,try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay: "Sunday")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane) ),
                   (DaySpecifics.monday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay: "Monday")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane)),
                   (DaySpecifics.tuesday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay: "Tuesday")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane)),
                   (DaySpecifics.wednesday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay: "Wednesday")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane)),
                   (DaySpecifics.thursday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay: "Thursday")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane)),
                   (DaySpecifics.friday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay: "Friday")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane)),
                   (DaySpecifics.saturday, try! DBMS.queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay: "Saturday")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane))

                  ]
                  ),
              (
                DataParts.monthall,
                 [
                 
                     (DaySpecifics.january, try! DBMS.queryMonthlyCarbonAll(month: "January")/normaliseMonthlyAll()),
                     (DaySpecifics.febuary, try! DBMS.queryMonthlyCarbonAll(month: "February")/normaliseMonthlyAll()),
                     (DaySpecifics.march, try! DBMS.queryMonthlyCarbonAll(month: "March")/normaliseMonthlyAll()),
                     (DaySpecifics.april, try! DBMS.queryMonthlyCarbonAll(month: "April")/normaliseMonthlyAll()),
                     (DaySpecifics.may, try! DBMS.queryMonthlyCarbonAll(month: "May")/normaliseMonthlyAll()),
                     (DaySpecifics.june, try! DBMS.queryMonthlyCarbonAll(month: "June")/normaliseMonthlyAll()),
                     (DaySpecifics.july, try! DBMS.queryMonthlyCarbonAll(month: "July")/normaliseMonthlyAll()),
                     (DaySpecifics.august, try! DBMS.queryMonthlyCarbonAll(month: "August")/normaliseMonthlyAll()),
                     (DaySpecifics.september,try! DBMS.queryMonthlyCarbonAll(month:"September")/normaliseMonthlyAll()),
                     (DaySpecifics.october, try! DBMS.queryMonthlyCarbonAll(month: "October")/normaliseMonthlyAll()),
                     (DaySpecifics.november, try! DBMS.queryMonthlyCarbonAll(month: "November")/normaliseMonthlyAll()),
                     (DaySpecifics.december, try! DBMS.queryMonthlyCarbonAll(month: "December")/normaliseMonthlyAll()),
                 ]
                ),
              (
                DataParts.monthcar,
                [
                    (DaySpecifics.january, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "January")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                     (DaySpecifics.febuary, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "February")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                     (DaySpecifics.march, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "March")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                     (DaySpecifics.april, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "April")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                     (DaySpecifics.may, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "May")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                     (DaySpecifics.june, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "June")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                     (DaySpecifics.july, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "July")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                     (DaySpecifics.august, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "August")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                     (DaySpecifics.september, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "September")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                     (DaySpecifics.october, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "October")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                     (DaySpecifics.november, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "November")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                     (DaySpecifics.december, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "December")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar))
                 ]
                ),
              (
                DataParts.monthwalk,
                 [
                     (DaySpecifics.january, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "January")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                     (DaySpecifics.febuary, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "February")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                     (DaySpecifics.march, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "March")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                     (DaySpecifics.april, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "April")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                     (DaySpecifics.may, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "May")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                     (DaySpecifics.june, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "June")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                     (DaySpecifics.july, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "July")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                     (DaySpecifics.august, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "August")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                     (DaySpecifics.september, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "September")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                     (DaySpecifics.october, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "October")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                     (DaySpecifics.november, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "November")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                     (DaySpecifics.december, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "December")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk))
                 ]
                ),
              (
                DataParts.monthtrain,
                [
                   (DaySpecifics.january, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "January")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                    (DaySpecifics.febuary, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "February")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                    (DaySpecifics.march, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "March")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                    (DaySpecifics.april, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "April")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                    (DaySpecifics.may, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "May")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                    (DaySpecifics.june, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "June")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                    (DaySpecifics.july, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "July")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                    (DaySpecifics.august, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "August")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                    (DaySpecifics.september, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "September")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                    (DaySpecifics.october, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "October")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                    (DaySpecifics.november, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "November")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                    (DaySpecifics.december, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "December")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain))
                ]
                ),
              (
            DataParts.monthplane,
                [
                   (DaySpecifics.january, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "January")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
                   (DaySpecifics.febuary, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "February")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
                   (DaySpecifics.march, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "March")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
                   (DaySpecifics.april, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "April")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
                   (DaySpecifics.may, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "May")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
                   (DaySpecifics.june, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "June")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
                   (DaySpecifics.july, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "July")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
                   (DaySpecifics.august, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "August")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
                   (DaySpecifics.september, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "September")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
                   (DaySpecifics.october, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "October")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
                   (DaySpecifics.november, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "November")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
                   (DaySpecifics.december, try! DBMS.queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "December")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane))

                ]
        ),
              (
                DataParts.yearall,
              [
                  (DaySpecifics.minusThreeYearsEnum, try! DBMS.queryYearlyCarbonAll(year: minusThreeYearsString)/normaliseYearlyAll()),
                  (DaySpecifics.minusTwoYearsEnum, try! DBMS.queryYearlyCarbonAll(year: minusTwoYearsString)/normaliseYearlyAll()),
                  (DaySpecifics.lastYearEnum, try! DBMS.queryYearlyCarbonAll(year: lastYearString)/normaliseYearlyAll()),
                  (DaySpecifics.thisYearEnum, try! DBMS.queryYearlyCarbonAll(year: thisYearString)/normaliseYearlyAll()),
                  (DaySpecifics.nextYearEnum, try! DBMS.queryYearlyCarbonAll(year: nextYearString)/normaliseYearlyAll()),
                  (DaySpecifics.plusTwoYearsEnum, try! DBMS.queryYearlyCarbonAll(year: plusTwoYearsString)/normaliseYearlyAll()),
                  (DaySpecifics.plusThreeYearsEnum, try! DBMS.queryYearlyCarbonAll(year: plusThreeYearsString)/normaliseYearlyAll()),
                  
              ]
      ),
      (
          DataParts.yearcar,
              [
                (DaySpecifics.minusThreeYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: minusThreeYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)),
                  (DaySpecifics.minusTwoYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: minusTwoYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)),
                  (DaySpecifics.lastYearEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: lastYearString)/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)),
                  (DaySpecifics.thisYearEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: thisYearString)/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)),
                  (DaySpecifics.nextYearEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: nextYearString)/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)),
                  (DaySpecifics.plusTwoYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: plusTwoYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)),
                  (DaySpecifics.plusThreeYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: plusThreeYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)),
              ]
      ),
    (
         DataParts.yearwalk,
             [
                (DaySpecifics.minusThreeYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.walking, year: minusThreeYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk)),
                 (DaySpecifics.minusTwoYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.walking, year: minusTwoYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk)),
                 (DaySpecifics.lastYearEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.walking, year: lastYearString)/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk)),
                 (DaySpecifics.thisYearEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.walking, year: thisYearString)/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk)),
                 (DaySpecifics.nextYearEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.walking, year: nextYearString)/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk)),
                 (DaySpecifics.plusTwoYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.walking, year: plusTwoYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk)),
                 (DaySpecifics.plusThreeYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.walking, year: plusThreeYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk))
             ]
     ),
                  (
       DataParts.yeartrain,
           [
                (DaySpecifics.minusThreeYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train, year: minusThreeYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain)),
                (DaySpecifics.minusTwoYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train, year: minusTwoYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain)),
                (DaySpecifics.lastYearEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train, year: lastYearString)/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain)),
                (DaySpecifics.thisYearEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train, year: thisYearString)/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain)),
                (DaySpecifics.nextYearEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train, year: nextYearString)/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain)),
                (DaySpecifics.plusTwoYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train, year: plusTwoYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain)),
                (DaySpecifics.plusThreeYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train, year: plusThreeYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain))
           ]
    ),
      (
          DataParts.yearplane,
              [
                (DaySpecifics.minusThreeYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane, year: minusThreeYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane)),
                (DaySpecifics.minusTwoYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane, year: minusTwoYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane)),
                (DaySpecifics.lastYearEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane, year: lastYearString)/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane)),
                (DaySpecifics.thisYearEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane, year: thisYearString)/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane)),
                (DaySpecifics.nextYearEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane, year: nextYearString)/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane)),
                (DaySpecifics.plusTwoYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane, year: plusTwoYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane)),
                (DaySpecifics.plusThreeYearsEnum, try! DBMS.queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane, year: plusThreeYearsString)/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane))
              ]
      ),
               ]
    
}

