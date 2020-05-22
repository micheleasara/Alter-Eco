import SwiftUI

struct Gridlines: View {
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    //Value represents the sum of the pickers so we know what the view currently is.E.g. if the sum is 1 then that means that car and day views have been selected and the gridlines will have to adjust for the maximum value within the queries for that range.
    var numGridLines : UInt
    let maximumValue: Double

    var body: some View {
        let carbonUnit: String = "Carbon kgs"
        let decimalPlaces: String = decimalFormat(maxValue: maximumValue)
        let savedOrEmitted: String
        
        return ZStack {
//                Text(String(carbonUnit))
//                    .font(Font.system(size: 12, design: .default))
//                    .offset(x:CGFloat(self.screenMeasurements.broadcastedWidth)/60+CGFloat(self.screenMeasurements.broadcastedWidth)/3, y:-CGFloat(self.screenMeasurements.broadcastedHeight)/7.2)
//                savedOrEmittedLabel(savedOrEmitted: savedOrEmitted)
                //For each gridline, the dimensions are set and the label that it represents is brought in from the switch statement above which found the max value.
                ForEach(0..<numGridLines, id: \.self) { lineNum in
                    self.labelledLine(decimalPlaces: decimalPlaces, lineNum: lineNum)
                }
            }
        }
    
    func savedOrEmittedLabel(savedOrEmitted: String) -> some View {
        Text(String(savedOrEmitted))
        .font(.caption)
        .bold()
        .offset(x:self.screenMeasurements.broadcastedWidth/60 + self.screenMeasurements.broadcastedWidth/2.75, y:-self.screenMeasurements.broadcastedHeight/8.3)
    }
    
    func labelledLine(decimalPlaces: String, lineNum: UInt) -> some View {
        let maxIDX = Double(numGridLines - 2)
        var unit = maximumValue/maxIDX
        unit = (unit/0.1).rounded(.down) * 0.1
        let label = unit * Double(lineNum)
        
        return ZStack {
            Rectangle()
                .foregroundColor(Color("secondary_label"))
                .offset(y: self.verticalOffset(lineNum: lineNum))
                .frame(height: self.screenMeasurements.broadcastedHeight/5000)
                .frame(width: self.screenMeasurements.broadcastedWidth/1.2)
            
            Text(String(format: decimalPlaces, label))
                .font(.caption)
                .offset(x:-self.screenMeasurements.broadcastedWidth/1000 - self.screenMeasurements.broadcastedWidth/2.17, y: verticalOffset(lineNum: lineNum))
                .foregroundColor(Color("tertiary_label"))
        }
    }
    
    func verticalOffset(lineNum: UInt) -> CGFloat {
        return CGFloat(lineNum) * self.screenMeasurements.broadcastedHeight/35 - self.screenMeasurements.broadcastedHeight/9.3
    }
    
    func decimalFormat(maxValue: Double) -> String {
        if maxValue > 0 && maxValue < 100 {
            return "%.1f"
        }
        return "%.0f"
    }
}

struct gridlines_Previews: PreviewProvider {
    static var previews: some View {
        return Gridlines(numGridLines: 5, maximumValue: 1000.0).environmentObject(ScreenMeasurements())
    }
}
