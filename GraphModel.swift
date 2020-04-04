//
//  GraphModel.swift
//  Alter Eco
//
//  Created by e withnell on 04/04/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import Foundation

let AV_UK_DAILYCARBON: Double = 2200

func findMaxValue(value: Int) -> Double {
    var maxVal: Double
    switch (value) {
    case 0:
    maxVal = normaliseDailyAll()
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
    var carbonUnit: String
    var decimalPlaces: String
    var savedOrEmitted: String
    var maxVal: Double
    
    //Units change depending on whether the total amount of carbon in grams is over or under 1000 (helps ensure the y-axis labels fit on the screen and adds clarity
    if (currentMax>1000&&currentMax<=10000){//This adjusts the value from grams to kilograms and changes the value to display to 1 d.p (otherwise it will be to 0dp)
        maxVal=currentMax/1000
        carbonUnit="  Carbon kgs"
        decimalPlaces="%.1f"
    }
    if (currentMax>10000) {//This adjusts the value from grams to kilograms and changes the value to display to 1 d.p (otherwise it will be to 0dp)
        maxVal=currentMax/1000
        carbonUnit="  Carbon kgs"
        decimalPlaces="%.0f"
    }//If the carbon value is very small (below 10grams) then this ensures that the value is displayed to 1 d.p., otherwise, values over 10 grams are displaced to 0 d.p
    else if (currentMax<10) {
        carbonUnit="Carbon grams"
        decimalPlaces="%.1f"
        maxVal=currentMax
    }
    else {
        carbonUnit="Carbon grams"
        decimalPlaces="%.0f"
        maxVal=currentMax
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
    
    var colour: String
    
    if (queryDailyCarbonAll(hourStart: "00:00:00", hourEnd: "24:00:00") > AV_UK_DAILYCARBON) {
        colour = "redGraphBar"
    }
    else {
        colour = "graphBars"
        
}
    return colour
}

func normaliseData(motionType: MeasuredActivity.MotionType, datapart: DataParts) -> Double {
    
    var max_data=0.0
    
    switch (datapart) {
    case .daycar,.dayplane,.daytrain, .daywalk:
        
    max_data = max(queryDailyCarbon(motionType: motionType,hourStart: "00:00:00", hourEnd: "02:00:00"),queryDailyCarbon(motionType: motionType,hourStart: "02:00:00", hourEnd: "04:00:00"), queryDailyCarbon(motionType: motionType,hourStart: "04:00:00", hourEnd: "06:00:00"),queryDailyCarbon(motionType: motionType,hourStart: "06:00:00", hourEnd: "08:00:00"), queryDailyCarbon(motionType: motionType,hourStart: "08:00:00", hourEnd: "10:00:00"),queryDailyCarbon(motionType: motionType,hourStart: "10:00:00", hourEnd: "12:00:00"),queryDailyCarbon(motionType: motionType,hourStart: "12:00:00", hourEnd: "14:00:00"),queryDailyCarbon(motionType: motionType,hourStart: "14:00:00", hourEnd: "16:00:00"), queryDailyCarbon(motionType: motionType,hourStart: "16:00:00", hourEnd: "18:00:00"), queryDailyCarbon(motionType: motionType,hourStart: "18:00:00", hourEnd: "20:00:00"), queryDailyCarbon(motionType: motionType,hourStart: "20:00:00", hourEnd: "22:00:00"),queryDailyCarbon(motionType: motionType,hourStart: "22:00:00", hourEnd: "24:00:00"))
        
    case .weekcar,.weekplane,.weektrain, .weekwalk:
        
    max_data = max(queryWeeklyCarbon(motionType: motionType, weekDayToDisplay: "Sunday"),
    queryWeeklyCarbon(motionType: motionType,  weekDayToDisplay: "Monday"),
    queryWeeklyCarbon(motionType: motionType,  weekDayToDisplay: "Tuesday"),
    queryWeeklyCarbon(motionType: motionType,  weekDayToDisplay: "Wednesday"),
    queryWeeklyCarbon(motionType: motionType,  weekDayToDisplay: "Thursday"),
    queryWeeklyCarbon(motionType: motionType,  weekDayToDisplay: "Friday"),
    queryWeeklyCarbon(motionType: motionType, weekDayToDisplay: "Saturday"))
        
    case .monthcar,.monthplane,.monthtrain, .monthwalk:
        
    max_data = max(queryMonthlyCarbon(motionType:motionType, month: "January"), queryMonthlyCarbon(motionType:motionType, month: "February"), queryMonthlyCarbon(motionType:motionType, month: "March"), queryMonthlyCarbon(motionType:motionType, month: "April"),queryMonthlyCarbon(motionType:motionType, month: "May"),queryMonthlyCarbon(motionType:motionType, month: "June"),queryMonthlyCarbon(motionType:motionType, month: "July"),queryMonthlyCarbon(motionType:motionType, month: "August"),queryMonthlyCarbon(motionType:motionType, month: "September"),queryMonthlyCarbon(motionType:motionType, month: "October"),queryMonthlyCarbon(motionType:motionType, month: "November"), queryMonthlyCarbon(motionType:motionType, month: "December"))
    case .yearcar,.yearplane,.yeartrain, .yearwalk:
        
        max_data = max(queryYearlyCarbon(motionType: motionType, year: "2014"),queryYearlyCarbon(motionType: motionType, year: "2015"),queryYearlyCarbon(motionType: motionType, year: "2016"),queryYearlyCarbon(motionType: motionType, year: "2017"),queryYearlyCarbon(motionType: motionType, year: "2018"),queryYearlyCarbon(motionType: motionType, year: "2019"),queryYearlyCarbon(motionType: motionType, year: "2020"))
    default:
        max_data=1.0
    }
    //prevent divide by zero error
    if (max_data==0) {
        max_data=1.0
    }
    return max_data
}

func normaliseDailyAll() -> Double {
    
       var max_data = max(queryDailyCarbonAll(hourStart: "00:00:00", hourEnd: "02:00:00"),queryDailyCarbonAll(hourStart: "02:00:00", hourEnd: "04:00:00"), queryDailyCarbonAll(hourStart: "04:00:00", hourEnd: "06:00:00"),queryDailyCarbonAll(hourStart: "06:00:00", hourEnd: "08:00:00"), queryDailyCarbonAll(hourStart: "08:00:00", hourEnd: "10:00:00"),queryDailyCarbonAll(hourStart: "10:00:00", hourEnd: "12:00:00"),queryDailyCarbonAll(hourStart: "12:00:00", hourEnd: "14:00:00"),queryDailyCarbonAll(hourStart: "14:00:00", hourEnd: "16:00:00"), queryDailyCarbonAll(hourStart: "16:00:00", hourEnd: "18:00:00"), queryDailyCarbonAll(hourStart: "18:00:00", hourEnd: "20:00:00"), queryDailyCarbonAll(hourStart: "20:00:00", hourEnd: "22:00:00"),queryDailyCarbonAll(hourStart: "22:00:00", hourEnd: "24:00:00"))
    //prevent divide by zero error
    if (max_data==0)
    {
        max_data=1.0
    }
    
  return max_data
}

func normaliseWeeklyAll() -> Double {

    var max_data = max(queryWeeklyCarbonAll(weekDayToDisplay: "Sunday"),
    queryWeeklyCarbonAll( weekDayToDisplay: "Monday"),
    queryWeeklyCarbonAll(weekDayToDisplay: "Tuesday"),
    queryWeeklyCarbonAll(weekDayToDisplay: "Wednesday"),
    queryWeeklyCarbonAll(weekDayToDisplay: "Thursday"),
    queryWeeklyCarbonAll(weekDayToDisplay: "Friday"),
    queryWeeklyCarbonAll(weekDayToDisplay: "Saturday"))
    
    //prevent divide by zero error
    if (max_data==0)
    {
        max_data=1.0
    }
  return max_data
    
}

func normaliseMonthlyAll() -> Double {
    var max_data = max(queryMonthlyCarbonAll(month: "January"),queryMonthlyCarbonAll(month: "February"),queryMonthlyCarbonAll(month: "March"),queryMonthlyCarbonAll(month: "April"), queryMonthlyCarbonAll(month: "May"),queryMonthlyCarbonAll(month: "June"),queryMonthlyCarbonAll(month: "July"), queryMonthlyCarbonAll(month: "August"),queryMonthlyCarbonAll(month:"September"), queryMonthlyCarbonAll(month: "October"), queryMonthlyCarbonAll(month: "November"),queryMonthlyCarbonAll(month: "December"))
    
    //prevent divide by zero error
    if (max_data==0)
    {
        max_data=1.0
    }
    
  return max_data
}

func normaliseYearlyAll() -> Double {
     var max_data = max(queryYearlyCarbonAll(year: "2014"),queryYearlyCarbonAll(year: "2015"),queryYearlyCarbonAll(year: "2016"), queryYearlyCarbonAll(year: "2017"),queryYearlyCarbonAll(year: "2018"),queryYearlyCarbonAll(year: "2019"),queryYearlyCarbonAll(year: "2020"))
    
    //prevent divide by zero error
    if (max_data==0)
    {
        max_data=1.0
    }
    
  return max_data
}

//A dictionary data structure for the bar chart.
//Access by the data type 'DataParts' declared in the file DataClassGraph. This value is determined by the picker sum (e.g. if day + car view is selected the picker sum will be '1' and therefore DataParts.daycar (position 1 in the dictionary) will be displayed).
var data: [(dayPart: DataParts, carbonByDate: [(day:DaySpecifics, carbon:Double)])] =
        [
            (//Access dictionary via this key
                DataParts.dayall,
               [//The nested dictionary holds the individual values e.g. for day this is the normalised hourly time points
                  (DaySpecifics.twohour, queryDailyCarbonAll(hourStart: "00:00:00", hourEnd: "02:00:00")/normaliseDailyAll()),
                    (DaySpecifics.fourhour, queryDailyCarbonAll(hourStart: "02:00:00", hourEnd: "04:00:00")/normaliseDailyAll()),
                    (DaySpecifics.sixhour, queryDailyCarbonAll(hourStart: "04:00:00", hourEnd: "06:00:00")/normaliseDailyAll()),
                    (DaySpecifics.eighthour, queryDailyCarbonAll(hourStart: "06:00:00", hourEnd: "08:00:00")/normaliseDailyAll()),
                    (DaySpecifics.tenhour, queryDailyCarbonAll(hourStart: "08:00:00", hourEnd: "10:00:00")/normaliseDailyAll()),
                    (DaySpecifics.twelvehour, queryDailyCarbonAll(hourStart: "10:00:00", hourEnd: "12:00:00")/normaliseDailyAll()),
                    (DaySpecifics.fourteenhour, queryDailyCarbonAll(hourStart: "12:00:00", hourEnd: "14:00:00")/normaliseDailyAll()),
                    (DaySpecifics.sixteenhour, queryDailyCarbonAll(hourStart: "14:00:00", hourEnd: "16:00:00")/normaliseDailyAll()),
                    (DaySpecifics.eighteenhour, queryDailyCarbonAll(hourStart: "16:00:00", hourEnd: "18:00:00")/normaliseDailyAll()),
                    (DaySpecifics.twentyhour, queryDailyCarbonAll(hourStart: "18:00:00", hourEnd: "20:00:00")/normaliseDailyAll()),
                    (DaySpecifics.twentytwohour, queryDailyCarbonAll(hourStart: "20:00:00", hourEnd: "22:00:00")/normaliseDailyAll()),
                    (DaySpecifics.twentyfourhour, queryDailyCarbonAll(hourStart: "22:00:00", hourEnd: "24:00:00")/normaliseDailyAll()),
                ]
            ),
            (
              DataParts.daycar,
              [
                (DaySpecifics.twohour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "00:00:00", hourEnd: "02:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                  (DaySpecifics.fourhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "02:00:00", hourEnd: "04:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                  (DaySpecifics.sixhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "04:00:00", hourEnd: "06:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                  (DaySpecifics.eighthour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "06:00:00", hourEnd: "08:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                  (DaySpecifics.tenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "08:00:00", hourEnd: "10:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                  (DaySpecifics.twelvehour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "10:00:00", hourEnd:  "12:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                  (DaySpecifics.fourteenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "12:00:00", hourEnd: "14:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                  (DaySpecifics.sixteenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "14:00:00", hourEnd: "16:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                  (DaySpecifics.eighteenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "16:00:00", hourEnd: "18:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                  (DaySpecifics.twentyhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "18:00:00", hourEnd: "20:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                  (DaySpecifics.twentytwohour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "20:00:00", hourEnd: "22:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),
                  (DaySpecifics.twentyfourhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.car, hourStart: "22:00:00", hourEnd: "24:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.daycar)),

              ]
                                              
                  ),
                  (
                      DataParts.daywalk,
              [
                (DaySpecifics.twohour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "00:00:00", hourEnd: "02:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                  (DaySpecifics.fourhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "02:00:00", hourEnd: "04:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                  (DaySpecifics.sixhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "04:00:00", hourEnd: "06:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                  (DaySpecifics.eighthour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "06:00:00", hourEnd: "08:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                  (DaySpecifics.tenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "08:00:00", hourEnd: "10:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                  (DaySpecifics.twelvehour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "10:00:00", hourEnd: "12:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                  (DaySpecifics.fourteenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "12:00:00", hourEnd: "14:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                  (DaySpecifics.sixteenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "14:00:00", hourEnd: "16:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                  (DaySpecifics.eighteenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "16:00:00", hourEnd: "18:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                  (DaySpecifics.twentyhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "18:00:00", hourEnd: "20:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                  (DaySpecifics.twentytwohour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "20:00:00", hourEnd: "22:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
                  (DaySpecifics.twentyfourhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.walking, hourStart: "22:00:00", hourEnd: "24:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.daywalk)),
              ]
                  ),
              (
                  DataParts.daytrain,
              [
                (DaySpecifics.twohour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "00:00:00", hourEnd: "02:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                  (DaySpecifics.fourhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "02:00:00", hourEnd: "04:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                  (DaySpecifics.sixhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "04:00:00", hourEnd: "06:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                  (DaySpecifics.eighthour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "06:00:00", hourEnd: "08:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                  (DaySpecifics.tenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "08:00:00", hourEnd: "10:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                  (DaySpecifics.twelvehour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "10:00:00", hourEnd: "12:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                  (DaySpecifics.fourteenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "12:00:00", hourEnd: "14:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                  (DaySpecifics.sixteenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "14:00:00", hourEnd: "16:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                  (DaySpecifics.eighteenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "16:00:00", hourEnd: "18:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                  (DaySpecifics.twentyhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "18:00:00", hourEnd: "20:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                  (DaySpecifics.twentytwohour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "20:00:00", hourEnd: "22:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
                  (DaySpecifics.twentyfourhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.train, hourStart: "22:00:00", hourEnd: "24:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.daytrain)),
              ]

              ),
              (
                DataParts.dayplane,
             [
                (DaySpecifics.twohour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "00:00:00", hourEnd: "02:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                (DaySpecifics.fourhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "02:00:00", hourEnd: "04:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                (DaySpecifics.sixhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "04:00:00", hourEnd: "06:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                (DaySpecifics.eighthour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "06:00:00", hourEnd: "08:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                (DaySpecifics.tenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "08:00:00", hourEnd: "10:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                (DaySpecifics.twelvehour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "10:00:00", hourEnd: "12:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                (DaySpecifics.fourteenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "12:00:00", hourEnd: "14:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                (DaySpecifics.sixteenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "14:00:00", hourEnd: "16:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                (DaySpecifics.eighteenhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "16:00:00", hourEnd: "18:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                (DaySpecifics.twentyhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "18:00:00", hourEnd: "20:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                (DaySpecifics.twentytwohour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "20:00:00", hourEnd: "22:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),
                (DaySpecifics.twentyfourhour, queryDailyCarbon(motionType: MeasuredActivity.MotionType.plane, hourStart: "22:00:00", hourEnd: "24:00:00")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.dayplane)),

             ]
     ),
              (
                DataParts.weekall,
              [
                  (DaySpecifics.sunday, queryWeeklyCarbonAll(weekDayToDisplay: "Sunday")/normaliseWeeklyAll()),
                  (DaySpecifics.monday, queryWeeklyCarbonAll(weekDayToDisplay: "Monday")/normaliseWeeklyAll()),
                  (DaySpecifics.tuesday, queryWeeklyCarbonAll(weekDayToDisplay: "Tuesday")/normaliseWeeklyAll()),
                  (DaySpecifics.wednesday, queryWeeklyCarbonAll(weekDayToDisplay: "Wednesday")/normaliseWeeklyAll()),
                  (DaySpecifics.thursday, queryWeeklyCarbonAll(weekDayToDisplay: "Thursday")/normaliseWeeklyAll()),
                  (DaySpecifics.friday, queryWeeklyCarbonAll(weekDayToDisplay: "Friday")/normaliseWeeklyAll()),
                  (DaySpecifics.saturday, queryWeeklyCarbonAll(weekDayToDisplay: "Saturday")/normaliseWeeklyAll()),
              ]
              ),
              (
                DataParts.weekcar,
              [
                (DaySpecifics.sunday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay: "Sunday")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar)),
                  (DaySpecifics.monday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay: "Monday")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar)),
                  (DaySpecifics.tuesday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay: "Tuesday")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar)),
                  (DaySpecifics.wednesday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay: "Wednesday")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar)),
                  (DaySpecifics.thursday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay: "Thursday")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar)),
                  (DaySpecifics.friday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay: "Friday")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar)),
                  (DaySpecifics.saturday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.car, weekDayToDisplay: "Saturday")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar))
              ]
              ),
              (
                DataParts.weekwalk,
              [
                  (DaySpecifics.sunday,queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.walking, weekDayToDisplay: "Sunday")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk) ),
                  (DaySpecifics.monday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.walking, weekDayToDisplay: "Monday")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk)),
                  (DaySpecifics.tuesday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.walking, weekDayToDisplay: "Tuesday")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk)),
                  (DaySpecifics.wednesday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.walking, weekDayToDisplay: "Wednesday")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk)),
                  (DaySpecifics.thursday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.walking, weekDayToDisplay: "Thursday")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk)),
                  (DaySpecifics.friday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.walking, weekDayToDisplay: "Friday")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk)),
                  (DaySpecifics.saturday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.walking, weekDayToDisplay: "Saturday")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk))
              ]
              ),
              (
                DataParts.weektrain,
           [
                (DaySpecifics.sunday,queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay: "Sunday")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain) ),
                (DaySpecifics.monday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay: "Monday")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain)),
                (DaySpecifics.tuesday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay: "Tuesday")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain)),
                (DaySpecifics.wednesday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay: "Wednesday")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain)),
                (DaySpecifics.thursday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay: "Thursday")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain)),
                (DaySpecifics.friday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay: "Friday")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain)),
                (DaySpecifics.saturday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.train, weekDayToDisplay: "Saturday")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain))
            ]
            ),
              (DataParts.weekplane,
              [
               (DaySpecifics.sunday,queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay: "Sunday")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane) ),
               (DaySpecifics.monday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay: "Monday")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane)),
               (DaySpecifics.tuesday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay: "Tuesday")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane)),
               (DaySpecifics.wednesday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay: "Wednesday")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane)),
               (DaySpecifics.thursday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay: "Thursday")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane)),
               (DaySpecifics.friday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay: "Friday")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane)),
               (DaySpecifics.saturday, queryWeeklyCarbon(motionType: MeasuredActivity.MotionType.plane, weekDayToDisplay: "Saturday")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.weekplane))

              ]
              ),
          (
            DataParts.monthall,
             [
             
                 (DaySpecifics.january, queryMonthlyCarbonAll(month: "January")/normaliseMonthlyAll()),
                 (DaySpecifics.febuary, queryMonthlyCarbonAll(month: "February")/normaliseMonthlyAll()),
                 (DaySpecifics.march, queryMonthlyCarbonAll(month: "March")/normaliseMonthlyAll()),
                 (DaySpecifics.april, queryMonthlyCarbonAll(month: "April")/normaliseMonthlyAll()),
                 (DaySpecifics.may, queryMonthlyCarbonAll(month: "May")/normaliseMonthlyAll()),
                 (DaySpecifics.june, queryMonthlyCarbonAll(month: "June")/normaliseMonthlyAll()),
                 (DaySpecifics.july, queryMonthlyCarbonAll(month: "July")/normaliseMonthlyAll()),
                 (DaySpecifics.august, queryMonthlyCarbonAll(month: "August")/normaliseMonthlyAll()),
                 (DaySpecifics.september,queryMonthlyCarbonAll(month:"September")/normaliseMonthlyAll()),
                 (DaySpecifics.october, queryMonthlyCarbonAll(month: "October")/normaliseMonthlyAll()),
                 (DaySpecifics.november, queryMonthlyCarbonAll(month: "November")/normaliseMonthlyAll()),
                 (DaySpecifics.december, queryMonthlyCarbonAll(month: "December")/normaliseMonthlyAll()),
             ]
            ),
          (
            DataParts.monthcar,
            [
                (DaySpecifics.january, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "January")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                 (DaySpecifics.febuary, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "February")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                 (DaySpecifics.march, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "March")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                 (DaySpecifics.april, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "April")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                 (DaySpecifics.may, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "May")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                 (DaySpecifics.june, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "June")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                 (DaySpecifics.july, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "July")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                 (DaySpecifics.august, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "August")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                 (DaySpecifics.september, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "September")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                 (DaySpecifics.october, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "October")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                 (DaySpecifics.november, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "November")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)),
                 (DaySpecifics.december, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.car, month: "December")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar))
             ]
            ),
          (
            DataParts.monthwalk,
             [
                 (DaySpecifics.january, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "January")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                 (DaySpecifics.febuary, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "February")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                 (DaySpecifics.march, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "March")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                 (DaySpecifics.april, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "April")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                 (DaySpecifics.may, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "May")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                 (DaySpecifics.june, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "June")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                 (DaySpecifics.july, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "July")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                 (DaySpecifics.august, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "August")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                 (DaySpecifics.september, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "September")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                 (DaySpecifics.october, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "October")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                 (DaySpecifics.november, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "November")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)),
                 (DaySpecifics.december, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.walking, month: "December")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk))
             ]
            ),
          (
            DataParts.monthtrain,
            [
               (DaySpecifics.january, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "January")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                (DaySpecifics.febuary, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "February")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                (DaySpecifics.march, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "March")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                (DaySpecifics.april, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "April")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                (DaySpecifics.may, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "May")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                (DaySpecifics.june, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "June")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                (DaySpecifics.july, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "July")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                (DaySpecifics.august, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "August")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                (DaySpecifics.september, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "September")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                (DaySpecifics.october, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "October")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                (DaySpecifics.november, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "November")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)),
                (DaySpecifics.december, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.train, month: "December")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain))
            ]
            ),
          (
        DataParts.monthplane,
            [
               (DaySpecifics.january, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "January")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
               (DaySpecifics.febuary, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "February")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
               (DaySpecifics.march, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "March")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
               (DaySpecifics.april, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "April")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
               (DaySpecifics.may, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "May")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
               (DaySpecifics.june, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "June")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
               (DaySpecifics.july, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "July")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
               (DaySpecifics.august, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "August")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
               (DaySpecifics.september, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "September")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
               (DaySpecifics.october, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "October")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
               (DaySpecifics.november, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "November")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane)),
               (DaySpecifics.december, queryMonthlyCarbon(motionType:MeasuredActivity.MotionType.plane, month: "December")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.monthplane))

            ]
    ),
          (
            DataParts.yearall,
          [
              (DaySpecifics.fourteen, queryYearlyCarbonAll(year: "2014")/normaliseYearlyAll()),
              (DaySpecifics.fifteen, queryYearlyCarbonAll(year: "2015")/normaliseYearlyAll()),
              (DaySpecifics.sixteen, queryYearlyCarbonAll(year: "2016")/normaliseYearlyAll()),
              (DaySpecifics.seventeen, queryYearlyCarbonAll(year: "2017")/normaliseYearlyAll()),
              (DaySpecifics.eighteen, queryYearlyCarbonAll(year: "2018")/normaliseYearlyAll()),
              (DaySpecifics.nineteen, queryYearlyCarbonAll(year: "2019")/normaliseYearlyAll()),
              (DaySpecifics.twenty, queryYearlyCarbonAll(year: "2020")/normaliseYearlyAll()),
              
          ]
  ),
  (
      DataParts.yearcar,
          [
            (DaySpecifics.fourteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: "2014")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)),
              (DaySpecifics.fifteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: "2015")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)),
              (DaySpecifics.sixteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: "2016")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)),
              (DaySpecifics.seventeen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: "2017")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)),
              (DaySpecifics.eighteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: "2018")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)),
              (DaySpecifics.nineteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: "2019")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)),
              (DaySpecifics.twenty, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.car, year: "2020")/normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)),
          ]
  ),
(
     DataParts.yearwalk,
         [
            (DaySpecifics.fourteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.walking, year: "2014")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk)),
             (DaySpecifics.fifteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.walking, year: "2015")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk)),
             (DaySpecifics.sixteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.walking, year: "2016")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk)),
             (DaySpecifics.seventeen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.walking, year: "2017")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk)),
             (DaySpecifics.eighteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.walking, year: "2018")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk)),
             (DaySpecifics.nineteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.walking, year: "2019")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk)),
             (DaySpecifics.twenty, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.walking, year: "2020")/normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk))
         ]
 ),
              (
   DataParts.yeartrain,
       [
            (DaySpecifics.fourteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train, year: "2014")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain)),
            (DaySpecifics.fifteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train, year: "2015")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain)),
            (DaySpecifics.sixteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train, year: "2016")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain)),
            (DaySpecifics.seventeen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train, year: "2017")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain)),
            (DaySpecifics.eighteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train, year: "2018")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain)),
            (DaySpecifics.nineteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train, year: "2019")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain)),
            (DaySpecifics.twenty, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.train, year: "2020")/normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain))
       ]
),
  (
      DataParts.yearplane,
          [
            (DaySpecifics.fourteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane, year: "2014")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane)),
            (DaySpecifics.fifteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane, year: "2015")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane)),
            (DaySpecifics.sixteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane, year: "2016")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane)),
            (DaySpecifics.seventeen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane, year: "2017")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane)),
            (DaySpecifics.eighteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane, year: "2018")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane)),
            (DaySpecifics.nineteen, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane, year: "2019")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane)),
            (DaySpecifics.twenty, queryYearlyCarbon(motionType: MeasuredActivity.MotionType.plane, year: "2020")/normaliseData(motionType: MeasuredActivity.MotionType.plane, datapart: DataParts.yearplane))
          ]
  ),
           ]


