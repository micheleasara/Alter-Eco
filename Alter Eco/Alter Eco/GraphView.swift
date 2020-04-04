import SwiftUI


struct GraphView: View {
    //Two picker variables set to 0 and the values are changed upon the users touch (changed values are found in the code below)
    //The following picker represents the options of 'day' 'week' 'month' 'year'
    @State var pickerSelectedItem = 0
    //The following picker represents the travel options of 'all' 'car' 'walk' 'train' 'plane'
    @State var pickerSelectedTwoItem = 0
    //A dictionary data structure for the bar chart.
    //Access by the data type 'DataParts' declared in the file DataClassGraph. This value is determined by the picker sum (e.g. if day + car view is selected the picker sum will be '1' and therefore DataParts.daycar (position 1 in the dictionary) will be displayed).
    @State var data: [(dayPart: DataParts, carbonByDate: [(day:DaySpecifics, carbon:Double)])] =
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
    
    var body: some View {//The top picker represents the time (e.g. day vs week) the user would like to view. For example, if the user selects the week picker, the picker would change to a value of 5. These values have been chosen to correctly index the dictionary above (when added to the picker value of the transport mode)
        VStack{
            Picker(selection: $pickerSelectedItem.animation(), label: Text("")) {
                Text(DataParts.day.name).tag(0)
                Text(DataParts.week.name).tag(5)
                Text(DataParts.month.name).tag(10)
                Text(DataParts.year.name).tag(15)
            }
              .pickerStyle(SegmentedPickerStyle())
              .padding()
            ZStack{//Gridlines (as declared in gridlines.swift) dynamically change depending on the max value for the view. The value of the sum of the pickers is passed to the gridlines to ensure they adjust for the view.
                gridlines(value:self.pickerSelectedItem+self.pickerSelectedTwoItem)
                //The bar chart is constructed here
                HStack {//The bar displayed depends on the two pickers chosen
                    ForEach(0..<self.data[pickerSelectedItem+pickerSelectedTwoItem].carbonByDate.count, id: \.self)
                    { i in
                        BarView(value: self.data[self.pickerSelectedItem+self.pickerSelectedTwoItem].carbonByDate[i].carbon,label: self.data[self.pickerSelectedItem+self.pickerSelectedTwoItem].carbonByDate[i].day.shortName,wid: self.pickerSelectedItem)}}}
            //Transport option picker
            Picker(selection: $pickerSelectedTwoItem.animation(), label: Image("")) {
            Text("All").tag(0)
            Image(systemName: "car").tag(1)
            Image(systemName: "person").tag(2)
            Image(systemName: "tram.fill").tag(3)
            Image(systemName: "airplane").tag(4)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
        }
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView()
    }
}

