import SwiftUI

struct BarChart: View {
    //@EnvironmentObject var screenMeasurements: ScreenMeasurements
    //Value represents the sum of the pickers so we know what the view currently is.E.g. if the sum is 1 then that means that car and day views have been selected and the gridlines will have to adjust for the maximum value within the queries for that range.
    let numGridLines : UInt
    let maximumValue: Double
    let size: CGSize
    let labelledDataPoints : LabelledDataPoints
    
    var body: some View {
        let carbonUnit: String = "Carbon kgs"
        let decimalPlaces: String = decimalFormat(maxValue: maximumValue)
        let savedOrEmitted: String
        let unit =  getUnitSpacing()
        return ZStack {
//                Text(String(carbonUnit))
//                    .font(Font.system(size: 12, design: .default))
//                    .offset(x:CGFloat(self.screenMeasurements.broadcastedWidth)/60+CGFloat(self.screenMeasurements.broadcastedWidth)/3, y:-CGFloat(self.screenMeasurements.broadcastedHeight)/7.2)
//                savedOrEmittedLabel(savedOrEmitted: savedOrEmitted)
                //For each gridline, the dimensions are set and the label that it represents is brought in from the switch statement above which found the max value.
                ForEach(0..<numGridLines, id: \.self) { lineNum in
                    self.labelledLine(decimalPlaces: decimalPlaces, lineNum: lineNum, unit: unit)
                }
            }
        }
    
    func dataBars(normalizeWith: Double) -> some View {
        var normalisation = normalizeWith
        if normalisation == 0.0 {
            normalisation = 1.0 // avoid divide-by-zero errors
        }
        return HStack {
            ForEach(dataGraph.data[timePickerSelection], id: \.self)
            {
                labelledDataPoint in
                BarView(height: labelledDataPoint.carbonByMotion[self.transportPickerSelection]! / normalisation,
                        label: labelledDataPoint.label,
                        timePickerSelection: self.timePickerSelection,
                        colour: self.barColour())
            }
        }
    }
    
    func maxAxisValue(actualMax: Double) -> Double {
        switch actualMax {
        case 0.001..<1:
            return actualMax * 1000
        case 1000..<Double.infinity:
            return actualMax / 1000
        default:
            return actualMax
        }
    }
    
    func barColour() -> String {
        var colour: String = "graphBars"
        let todayCarbon = dataGraph.data[1].last!.carbonByMotion
        var total = 0.0
        for motion in MeasuredActivity.MotionType.allCases {
            if let carbon = todayCarbon[motion] {
                if motion != .walking {
                    total += carbon
                }
            }
        }
        
        if total > AV_UK_DAILYCARBON {
            colour = "redGraphBar"
        }
        return colour
    }
    
    func savedOrEmittedLabel(savedOrEmitted: String) -> some View {
        Text(String(savedOrEmitted))
        .font(.caption)
        .bold()
        .offset(x:self.size.width/60 + self.size.width/2.75, y:-self.size.height/8.3)
    }
    
    func getUnitSpacing() -> Double {
        let maxIDX = Double(numGridLines - 1)
        let unit = maximumValue/maxIDX
        return (unit/0.1).rounded(.down) * 0.1
    }
    
    func labelledLine(decimalPlaces: String, lineNum: UInt, unit: Double) -> some View {
        let gridlineWidth = 0.8*size.width
        let label = unit * Double(lineNum)
        let textSize = size.width - gridlineWidth
        return ZStack {
//            Rectangle()
//                .foregroundColor(Color("secondary_label"))
//                .offset(y: self.verticalOffset(lineNum: lineNum))
//                .frame(height: self.screenMeasurements.height/5000)
//                .frame(width: self.screenMeasurements.width/1.2)
            Divider()
                .foregroundColor(Color("secondary_label"))
                .frame(width: gridlineWidth)
                .offset(y: self.verticalOffset(lineNum: lineNum))
            
            Text(String(format: decimalPlaces, label))
                .font(.caption)
                .frame(width: textSize)
                .offset(x:-gridlineWidth/2 - textSize/4, y: verticalOffset(lineNum: lineNum))
                .foregroundColor(Color("tertiary_label"))
            .allowsTightening(true)
        }
    }
    
    func verticalOffset(lineNum: UInt) -> CGFloat {
        return CGFloat(lineNum) * self.size.height/CGFloat(numGridLines)
    }
    
    func decimalFormat(maxValue: Double) -> String {
        if maxValue > 0 && maxValue < 100 {
            return "%g"
        }
        return "%.0f"
    }
}

struct gridlines_Previews: PreviewProvider {
    static var previews: some View {
        return BarChart(numGridLines: 5, maximumValue: 23, size: CGSize(width: UIScreen.main.bounds.width, height: 0.3*UIScreen.main.bounds.height))
    }
}
