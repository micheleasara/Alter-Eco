import SwiftUI

//                Text(String(carbonUnit))
//                    .font(Font.system(size: 12, design: .default))
//                    .offset(x:CGFloat(self.screenMeasurements.broadcastedWidth)/60+CGFloat(self.screenMeasurements.broadcastedWidth)/3, y:-CGFloat(self.screenMeasurements.broadcastedHeight)/7.2)
//                savedOrEmittedLabel(savedOrEmitted: savedOrEmitted)
                //For each gridline, the dimensions are set and the label that it represents is brought in from the switch statement above which found the max value.

struct BarChart: View {
    //@EnvironmentObject var screenMeasurements: ScreenMeasurements

    let numGridLines : UInt
    let labelledDataPoints : LabelledDataPoints
    let colour: String
    
    var body: some View {
        let spaceRatio = 0.2/CGFloat(self.labelledDataPoints.count - 1)
        let barWidthRatio = 0.8/CGFloat(self.labelledDataPoints.count)
        
        return GeometryReader { geometry in
            VStack(spacing: 0.05*geometry.size.height) {
                self.bars(barWidth: geometry.size.width * barWidthRatio,
                          spacing: geometry.size.width * spaceRatio,
                          maxBarHeight: 0.9*geometry.size.height)

                // axis is forced to be at the bottom even when no data
                // by using exploding stacks
                // see https://netsplit.com/swiftui/exploding-stacks/
                self.horizontalAxis(textWidth: geometry.size.width * barWidthRatio,
                                    textHeight: 0.05*geometry.size.height,
                                    spacing: geometry.size.width * spaceRatio)
                .frame(minWidth: 0, maxWidth: .infinity,
                minHeight: 0, maxHeight: .infinity,
                alignment: .bottom)
            }
        }
    }
    
    func bars(barWidth: CGFloat, spacing: CGFloat, maxBarHeight: CGFloat) -> some View {
        var normalisation = getMaxValue()
        if normalisation == 0.0 {
            normalisation = 1.0 // avoid divide-by-zero errors
        }
        
        return HStack(alignment:.bottom, spacing: spacing) {
            ForEach(self.labelledDataPoints, id: \.self)
            {
                labelledDataPoint in
                Rectangle()
                    .frame(width: barWidth,
                           height: maxBarHeight * CGFloat(labelledDataPoint.data / normalisation),
                           alignment:  .bottom)
            }
        }
    }
    
    func horizontalAxis(textWidth: CGFloat, textHeight: CGFloat, spacing: CGFloat) -> some View {
        HStack(alignment:.bottom, spacing: spacing) {
            ForEach(self.labelledDataPoints, id: \.self) {labelledDataPoint in
                Text(labelledDataPoint.label)
                    .font(.caption)
                    .allowsTightening(true)
                    .frame(width: textWidth, height: textHeight)
            }
        }
    }
    
    func getMaxValue() -> Double {
        var max = 0.0
        for labelledData in labelledDataPoints {
            if labelledData.data > max {
                max = labelledData.data
            }
        }
        
        return max
    }
    
    func unitConversion(actualMax: Double) -> Double {
        switch actualMax {
        case 0.001..<1:
            return 1000
        case 1000..<Double.infinity:
            return 0.001
        default:
            return 1.0
        }
    }
    
    func decimalFormat(maxValue: Double) -> String {
        if maxValue > 0 && maxValue < 100 {
            return "%g"
        }
        return "%.0f"
    }
}

struct BarChart_Previews: PreviewProvider {

    static var previews: some View {
        var testData : LabelledDataPoints = []
        for i in stride(from: 10, to: 120, by: 11) {
            testData.append(LabelledDataPoint(data: Double(i), label: i%2 == 0 ? String(i): ""))
        }
        testData.append(LabelledDataPoint(data: 500, label: String(500)))
        return BarChart(numGridLines: 5,
             labelledDataPoints: testData,
             colour: "graphBar").padding().frame(height:300)
        
    }
}
