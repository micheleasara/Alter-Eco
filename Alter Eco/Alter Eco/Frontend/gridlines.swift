import SwiftUI
let NUM_GRIDLINES = 8

struct Gridlines: View {
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    //Value represents the sum of the pickers so we know what the view currently is.E.g. if the sum is 1 then that means that car and day views have been selected and the gridlines will have to adjust for the maximum value within the queries for that range.
    var value: Int
    
    var body: some View {
        var maximumVal: Double
        maximumVal = findMaxValue(value: value)
        
        let maxVal: Double
        let carbonUnit: String
        let decimalPlaces: String
        let savedOrEmitted: String

        (maxVal, carbonUnit, decimalPlaces, savedOrEmitted) = findCorrectUnits(currentMax: maximumVal, value: value)
        
        return ZStack {
                Text(String(carbonUnit))
                    .font(Font.system(size: 12, design: .default))
                    .offset(x:CGFloat(self.screenMeasurements.broadcastedWidth)/60+CGFloat(self.screenMeasurements.broadcastedWidth)/3, y:-CGFloat(self.screenMeasurements.broadcastedHeight)/7.2)
                getSavedOrEmittedLabel(savedOrEmitted: savedOrEmitted)
                //For loop cycles through each grid line (currently 8, but this can be adjusted).
                //For each gridline, the dimensions are set and the label that it represents is brought in from the switch statement above which found the max value.
                
                ForEach(0..<NUM_GRIDLINES, id: \.self) { lineNum in
                    //Label is calculated from the maxVal adjusted for the number of the line currently in the for loop.
                    //E.g. if the line number is 1 then the value is 6/7* maxVal.
                    self.getLabelledLine(decimalPlaces: decimalPlaces, maxVal: maxVal, lineNum: lineNum)
                }
            }
        }
    
    func getSavedOrEmittedLabel(savedOrEmitted: String) -> some View {
        Text(String(savedOrEmitted))
        .font(.caption)
        .bold()
        .offset(x:+CGFloat(self.screenMeasurements.broadcastedWidth)/60+CGFloat(self.screenMeasurements.broadcastedWidth)/2.75, y:-CGFloat(self.screenMeasurements.broadcastedHeight)/8.3)
    }
    
    func getLabelledLine(decimalPlaces: String, maxVal: Double, lineNum: Int) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color("secondary_label"))
                .offset(y: self.getVerticalOffset(lineNum: lineNum))
                .frame(height: CGFloat(self.screenMeasurements.broadcastedHeight)/5000)
                .frame(width: (CGFloat(self.screenMeasurements.broadcastedWidth))/1.2)
            Text(String(format: decimalPlaces,((7.0-Double(lineNum))/7.0)*maxVal))
                        .font(.caption)
                        .offset(x:-CGFloat(self.screenMeasurements.broadcastedWidth)/100-CGFloat(self.screenMeasurements.broadcastedWidth)/2.17, y: getVerticalOffset(lineNum: lineNum))
                        .foregroundColor(Color("tertiary_label"))
        }
    }
    
    func getVerticalOffset(lineNum: Int) -> CGFloat {
        return CGFloat(Float(lineNum) * self.screenMeasurements.broadcastedHeight/35 - self.screenMeasurements.broadcastedHeight/9.3)
    }
}

struct gridlines_Previews: PreviewProvider {
    static var previews: some View {
        return Gridlines(value: 800).environmentObject(ScreenMeasurements())
    }
}
