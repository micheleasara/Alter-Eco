import SwiftUI

struct gridlines: View {
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    //Value represents the sum of the pickers so we know what the view currently is.E.g. if the sum is 1 then that means that car and day views have been selected and the gridlines will have to adjust for the maximum value within the queries for that range.
    var value: Int
    var body: some View {
        
        var maximumVal: Double
        maximumVal = findMaxValue(value: value)
        
        //Values for the dimensions of the gridlines to help ensure they fit on most device screens.
        let dimensionMultiplier=CGFloat(self.screenMeasurements.broadcastedHeight)/35
        let dimensionAdjustment=CGFloat(self.screenMeasurements.broadcastedHeight)/9.3
        
        let maxVal: Double
        let carbonUnit: String
        let decimalPlaces: String
        let savedOrEmitted: String
    
        (maxVal, carbonUnit, decimalPlaces, savedOrEmitted) = findCorrectUnits(currentMax: maximumVal, value: value)
       
        return
            ZStack {
                Text(String(carbonUnit))
                //changing font to dynamic font here means that the girdlines disappear (do not understand why yet)
                    .font(Font.system(size: 12, design: .default))
                    .offset(x:CGFloat(self.screenMeasurements.broadcastedWidth)/60+CGFloat(self.screenMeasurements.broadcastedWidth)/3, y:-CGFloat(self.screenMeasurements.broadcastedHeight)/7.2)
                
                Text(String(savedOrEmitted))
                .font(.caption)
                .bold()
                .offset(x:+CGFloat(self.screenMeasurements.broadcastedWidth)/60+CGFloat(self.screenMeasurements.broadcastedWidth)/2.75, y:-CGFloat(self.screenMeasurements.broadcastedHeight)/8.3)
                //For loop cycles through each grid line (currently 8, but this can be adjusted).
                //For each gridline, the dimensions are set and the label that it represents is brought in from the switch statement above which found the max value.
                
                ForEach(0..<8) { line in Rectangle()
                    .foregroundColor(Color("secondary_label"))
                    .offset(y: CGFloat(line) * dimensionMultiplier - dimensionAdjustment)
                    .frame(height: CGFloat(self.screenMeasurements.broadcastedHeight)/5000)
                    .frame(width: (CGFloat(self.screenMeasurements.broadcastedWidth))/1.2)
                    //Label is calculated from the maxVal adjusted for the number of the line currently in the for loop.
                    //E.g. if the line number is 1 then the value is 6/7* maxVal.
                    Text(String(format: decimalPlaces,((7.0-Double(line))/7.0)*maxVal))
                        .font(.caption)
                        .offset(x:-CGFloat(self.screenMeasurements.broadcastedWidth)/100-CGFloat(self.screenMeasurements.broadcastedWidth)/2.17, y: CGFloat(line) * dimensionMultiplier - dimensionAdjustment)
                        .foregroundColor(Color("tertiary_label"))
                                }
                    }
        }
}






