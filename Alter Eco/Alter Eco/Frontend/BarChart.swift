import SwiftUI

//                Text(String(carbonUnit))
//                    .font(Font.system(size: 12, design: .default))
//                    .offset(x:CGFloat(self.screenMeasurements.broadcastedWidth)/60+CGFloat(self.screenMeasurements.broadcastedWidth)/3, y:-CGFloat(self.screenMeasurements.broadcastedHeight)/7.2)
//                savedOrEmittedLabel(savedOrEmitted: savedOrEmitted)
                //For each gridline, the dimensions are set and the label that it represents is brought in from the switch statement above which found the max value.

struct BarChart: View {

    let values : [Double]
    let labels : [String]
    let infoOnBarTap : [String]
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
            VStack(spacing: 0.03*geometry.size.height) {
                ZStack() {
                    self.bars(barWidth: geometry.size.width * barWidthRatio,
                          spacing: geometry.size.width * barSpaceRatio,
                          maxBarHeight: 0.9*geometry.size.height)
                    
                    self.grid(textWidth: geometry.size.width * textWidthRatio,
                              maxBarHeight: 0.9*geometry.size.height,
                              spacing: geometry.size.width * textSpaceRatio)
                    
                    //if self.tappedBarID > 0 { Text(self.getBarInfo()) }
                }

                // axis is forced to be at the bottom even when no data
                // by using exploding stacks
                // see https://netsplit.com/swiftui/exploding-stacks/
                self.horizontalAxis(textWidth: geometry.size.width * textWidthRatio,
                                    textHeight: 0.07*geometry.size.height,
                                    spacing: geometry.size.width * textSpaceRatio)
            }.frame(minWidth: 0, maxWidth: .infinity,
            minHeight: 0, maxHeight: .infinity,
            alignment: .bottom)
        }
    }
    
    func grid(textWidth: CGFloat, maxBarHeight: CGFloat, spacing: CGFloat) -> some View {
        VStack(spacing: 0){
            HStack(alignment:.bottom, spacing: spacing) {
                ForEach(labels, id: \.self) { _ in
                    Divider().frame(width: textWidth, height: maxBarHeight, alignment: .bottomLeading)//.background(Color.blue)
                }
            }// exploding stack for alignment
            // combined with an outer frame for height sizing
            .frame(minWidth: 0, maxWidth: .infinity,
            minHeight: 0, maxHeight: maxBarHeight,
            alignment: .bottomLeading)
                .frame(height: maxBarHeight)
            Divider()
        }
        
    }
    
    func bars(barWidth: CGFloat, spacing: CGFloat, maxBarHeight: CGFloat) -> some View {
        var normalisation = CGFloat(values.max() ?? 1.0)
        if normalisation == 0.0 {
            normalisation = 1.0 // avoid divide-by-zero errors
        }
        normalisation = maxBarHeight / normalisation
        
        return HStack(alignment:.bottom, spacing: spacing) {
            ForEach(0..<self.values.count, id: \.self) { i in
                BarWithInfo(size:
                    CGSize(width: barWidth, height: normalisation*CGFloat(self.values[i])),
                            colour: self.colour,
                            information: self.infoOnBarTap[i])
            }
        }
    }
    
    func horizontalAxis(textWidth: CGFloat, textHeight: CGFloat, spacing: CGFloat) -> some View {
        HStack(alignment:.bottom, spacing: spacing) {
            ForEach(self.labels, id: \.self) { label in
                Text(label)
                    .font(.caption).fontWeight(.light)
                    .allowsTightening(true)
                    .frame(width: textWidth, height: textHeight, alignment: .bottomLeading)
            }
        // align axis to the leading edge via an exploding stack
        }.frame(minWidth: 0, maxWidth: .infinity,
        minHeight: 0, maxHeight: .infinity,
        alignment: .bottomLeading)
    }
}

struct BarChart_Previews: PreviewProvider {

    static let barsToLabelsRatios = [1, 2, 4]
    
    static var previews: some View {
        Group {
            BarChart(values: [0,0,0,0], labels: ["a","b","c","d"], infoOnBarTap: ["","","",""], colour: Color.green).padding()
                .previewLayout(PreviewLayout.fixed(width: 300, height: 160))
            .previewDisplayName("0-valued bars")
            
            ForEach(barsToLabelsRatios, id: \.self) { r in
                previewWithRatio(numBars: 12, ratio: r).padding()
                    .previewLayout(PreviewLayout.fixed(width: 300, height: 160))
                .previewDisplayName("Bars to labels ratio: " + String(r))
            }
        }
    }
    
    static func previewWithRatio(numBars: Int, ratio: Int) -> some View {
        var testData : [Double] = []
        var labels : [String] = []
        var infoBarsOnTap : [String] = []
        for i in stride(from: 0, to: numBars, by: 1) {
            testData.append(Double(i))
            if i % ratio == 0 {
                labels.append(String(i))
            }
            infoBarsOnTap.append(String(i))
        }
        
        return BarChart(values: testData, labels: labels, infoOnBarTap: infoBarsOnTap, colour: Color.green)
    }
}
