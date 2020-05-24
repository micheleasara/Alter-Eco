import SwiftUI

//                Text(String(carbonUnit))
//                    .font(Font.system(size: 12, design: .default))
//                    .offset(x:CGFloat(self.screenMeasurements.broadcastedWidth)/60+CGFloat(self.screenMeasurements.broadcastedWidth)/3, y:-CGFloat(self.screenMeasurements.broadcastedHeight)/7.2)
//                savedOrEmittedLabel(savedOrEmitted: savedOrEmitted)
                //For each gridline, the dimensions are set and the label that it represents is brought in from the switch statement above which found the max value.

struct BarChart: View {
    //@EnvironmentObject var screenMeasurements: ScreenMeasurements

    let numGridLines : UInt
    //let labelledDataPoints : LabelledDataPoints
    let values : [Double]
    let labels : [String]
    let colour: Color
    static let SPACING_RATIO : CGFloat = 0.2
    static let DRAWING_RATIO : CGFloat = 1 - SPACING_RATIO
    
    var body: some View {
        let barSpaceRatio = BarChart.SPACING_RATIO/CGFloat(self.values.count - 1)
        let barWidthRatio = BarChart.DRAWING_RATIO/CGFloat(self.values.count)
        let barsToLabelsRatio = CGFloat(self.values.count) / CGFloat(self.labels.count)
        let textSpaceRatio = barsToLabelsRatio * barSpaceRatio
        let textWidthRatio = barsToLabelsRatio * barWidthRatio
        
        return GeometryReader { geometry in
            VStack(spacing: 0.05*geometry.size.height) {
                self.bars(barWidth: geometry.size.width * barWidthRatio,
                          spacing: geometry.size.width * barSpaceRatio,
                          maxBarHeight: 0.9*geometry.size.height)

                // axis is forced to be at the bottom even when no data
                // by using exploding stacks
                // see https://netsplit.com/swiftui/exploding-stacks/
                self.horizontalAxis(textWidth: geometry.size.width * textWidthRatio,
                                    textHeight: 0.05*geometry.size.height,
                                    spacing: geometry.size.width * textSpaceRatio)
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
            ForEach(self.values, id: \.self) { value in
                Rectangle()
                    .fill(self.colour)
                    .frame(width: barWidth,
                           height: maxBarHeight * CGFloat(value / normalisation),
                           alignment:  .bottom)
            }
        }
    }
    
    func horizontalAxis(textWidth: CGFloat, textHeight: CGFloat, spacing: CGFloat) -> some View {
        HStack(alignment:.bottom, spacing: spacing) {
            ForEach(self.labels, id: \.self) { label in
                Text(label)
                    .font(.caption)
                    .allowsTightening(true)
                    .frame(width: textWidth, height: textHeight, alignment: .bottomLeading)
            }
        // align axis to the leading edge
        }.frame(minWidth: 0, maxWidth: .infinity,
        minHeight: 0, maxHeight: .infinity,
        alignment: .bottomLeading)
    }
    
    func getMaxValue() -> Double {
        return values.max()!
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

    static let barsToLabelsRatios = [1, 2, 4]
    
    static var previews: some View {
        Group {
            ForEach(barsToLabelsRatios, id: \.self) { r in
                BarChart_Previews.previewWithRatio(numBars: 12, ratio: r).padding().border(Color.black)
                    .previewLayout(PreviewLayout.fixed(width: 300, height: 160))
                .previewDisplayName("Bars to labels ratio: " + String(r))
            }
        }
    }
    
    static func previewWithRatio(numBars: Int, ratio: Int) -> some View {
        var testData : [Double] = []
        var labels : [String] = []
        for i in stride(from: 0, to: numBars, by: 1) {
            testData.append(Double(i))
            if i % ratio == 0 {
                labels.append(String(i))
            }
        }
        
        return BarChart(numGridLines: 5, values: testData, labels: labels, colour: Color.green)
    }
}
