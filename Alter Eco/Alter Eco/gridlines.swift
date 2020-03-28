import SwiftUI

struct gridlines: View {
     @EnvironmentObject var screenMeasurements: ScreenMeasurements
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
        if (maxVal==1)
        {maxVal=0}
        let dimensionMultiplier=CGFloat(self.screenMeasurements.broadcastedHeight)/35
        let dimensionAdjustment=CGFloat(self.screenMeasurements.broadcastedHeight)/8.5

        
        return
            ZStack {
                Text(String("Units:Carbon grams"))
                .font(Font.system(size: 12, design: .default))
                    .offset(x: -CGFloat(self.screenMeasurements.broadcastedWidth)/100-CGFloat(self.screenMeasurements.broadcastedWidth)/4, y: -CGFloat(self.screenMeasurements.broadcastedHeight)/7)
             ForEach(0..<8) { line in
      
             Rectangle()
                 .foregroundColor(Color("secondary_label"))
                 .zIndex(-100.0)
                 .offset(y: CGFloat(line) * dimensionMultiplier - dimensionAdjustment)
                 .frame(height: CGFloat(self.screenMeasurements.broadcastedHeight)/5000)
                .frame(width: (CGFloat(self.screenMeasurements.broadcastedWidth))/1.2)
                Text(String(format: "%.0f",((7.0-Double(line))/7.0)*maxVal))
                .font(Font.system(size: 12, design: .default))
                    .offset(x: -CGFloat(self.screenMeasurements.broadcastedWidth)/100-CGFloat(self.screenMeasurements.broadcastedWidth)/2.17, y: CGFloat(line) * dimensionMultiplier - dimensionAdjustment)
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
