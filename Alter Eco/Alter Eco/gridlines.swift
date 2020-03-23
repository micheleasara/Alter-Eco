import SwiftUI

struct gridlines: View {
    var value: Int
    var body: some View {
       var maxVal = normaliseDailyAll()
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
            maxVal = 70.0
        case 5:
            maxVal = normaliseWeeklyAll()
        case 6:
            maxVal = normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.weekcar)
        case 7:
            maxVal = normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.weekwalk)
        case 8:
            maxVal = normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.weektrain)
        case 9:
            maxVal = 70.0
        case 10:
            maxVal = normaliseMonthlyAll()
        case 11:
            maxVal = normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.monthcar)
        case 12:
            maxVal = normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.monthwalk)
        case 13:
            maxVal = normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.monthtrain)
        case 14:
            maxVal = 70.0
        case 15:
            maxVal = normaliseYearlyAll()
        case 16:
            maxVal = normaliseData(motionType: MeasuredActivity.MotionType.car, datapart: DataParts.yearcar)
        case 17:
            maxVal = normaliseData(motionType: MeasuredActivity.MotionType.walking, datapart: DataParts.yearwalk)
        case 18:
            maxVal = normaliseData(motionType: MeasuredActivity.MotionType.train, datapart: DataParts.yeartrain)
            
        default:
            maxVal = 70.0
        }
        
        return
            ZStack {
                Text(String("Units:g/km"))
                .font(Font.system(size: 12, design: .default))
                .offset(x: -170, y: -120)
             ForEach(0..<8) { line in
      
             Rectangle()
                 .foregroundColor(Color("secondary_label"))
                 .zIndex(-100.0)
                 .offset(y: CGFloat(line) * 25.0 - 93)
                 .frame(height: 0.5)
                 .frame(width: 300.0)
                Text(String(format: "%.0f",((7.0-Double(line))/7.0)*maxVal))
                .font(Font.system(size: 12, design: .default))
                 .offset(x: -170, y: CGFloat(line) * 25.0 - 93)
                 .foregroundColor(Color("tertiary_label"))
            }
        }
    }
}







  
//
//struct gridlines_Previews: PreviewProvider {
//    static var previews: some View {
//        gridlines()
//    }
//}
