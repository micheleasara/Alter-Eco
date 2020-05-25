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
    static let AXIS_DISTANCE_FROM_CHART: CGFloat = 8
    static let xAxisHeight = 2*BarChart.AXIS_DISTANCE_FROM_CHART
    static let yAxisWidth = 2*BarChart.AXIS_DISTANCE_FROM_CHART
    var body: some View {
        GeometryReader { geo in
            self.outOfBoundChart()
                .frame(width: geo.size.width - BarChart.yAxisWidth - BarChart.AXIS_DISTANCE_FROM_CHART, height: geo.size.height - BarChart.xAxisHeight)
        }
    }
    
    func outOfBoundChart() -> some View {
        GeometryReader { geometry in
            ZStack (alignment: .bottomLeading) {
                self.bars().overlay(self.grid())
                    .frame(width: geometry.size.width, height: geometry.size.height).offset(x:BarChart.yAxisWidth + BarChart.AXIS_DISTANCE_FROM_CHART)
                
                self.xAxis().frame(width: geometry.size.width, height: BarChart.xAxisHeight).offset(x:BarChart.yAxisWidth + BarChart.AXIS_DISTANCE_FROM_CHART, y: BarChart.xAxisHeight)
                
                self.yAxis().frame(width: BarChart.yAxisWidth, height: geometry.size.height)
            }
        }
    }
    
    func grid() -> some View {
        return verticalGridlines().overlay(
            horizontalGridlines())
    }
    
    func verticalGridlines() -> some View {
        let numGridlines = CGFloat(self.labels.count)
        
        return GeometryReader { geo in
        HStack(spacing: 0) {
            ForEach(self.labels, id: \.self) { _ in
                Divider().frame(width: geo.size.width/numGridlines, height: geo.size.height, alignment: .bottomLeading)
                }
            }
        }
    }
    
    func bars() -> some View {
        var normalisation = CGFloat(values.max() ?? 1.0)
        if normalisation == 0.0 {
            normalisation = 1.0 // avoid divide-by-zero errors
        }
        let barCount = CGFloat(values.count)
        
        return GeometryReader{ geo in
            HStack(alignment:.bottom, spacing: BarChart.SPACING_RATIO * geo.size.width / barCount) {
                ForEach(0..<self.values.count, id: \.self) { i in
                    BarWithInfo(size:
                        CGSize(width: geo.size.width * BarChart.DRAWING_RATIO / barCount,
                               height: CGFloat(self.values[i]) * geo.size.height/normalisation),
                                colour: self.colour,
                                information: self.infoOnBarTap[i])
                }
            }
        }
    }
    
    
    func horizontalGridlines() -> some View {
        let yAxisTicksCount = 4
        let ticksCount = CGFloat(yAxisTicksCount)
        return GeometryReader { geo in
            VStack(spacing: 0) {

                ForEach(1...yAxisTicksCount, id: \.self) {_ in
                    Divider().frame(width: geo.size.width, height: geo.size.height / ticksCount, alignment: .bottomLeading)
                }
            }
        }
    }
    
    func yAxis() -> some View {
        let yAxisTicksCount = 4
        let ticksCount = Double(yAxisTicksCount)
        var max = values.max() ?? 42 * ticksCount
        if max == 0 {
            max = 42 * ticksCount
        } else if max < 1 {
            max = max * 1000
        }
        let interval = Int((max / ticksCount).rounded(.up))

        return GeometryReader { geo in
            VStack(spacing: 0) {
                ForEach((0..<yAxisTicksCount).reversed(), id: \.self) { i in
                    Text(String(i*interval))
                        .allowsTightening(true)
                        .font(.system(size: 10))
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                        .fixedSize()
                        .frame(width: geo.size.width, height: geo.size.height / CGFloat(yAxisTicksCount), alignment: .bottomTrailing)
                }
            }
        }
    }
    
    func xAxis() -> some View {
        let ticksCount = CGFloat(labels.count)
        return GeometryReader { geo in
            HStack(alignment:.bottom, spacing: 0) {
                ForEach(self.labels, id: \.self) { label in
                    Text(label)
                        .allowsTightening(true)
                        .font(.system(size: 10))
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                        .fixedSize()
                        .frame(width: geo.size.width/ticksCount, height: geo.size.height, alignment: .bottomLeading)
                }
            }
        }
    }
}

struct BarChart_Previews: PreviewProvider {

    static let barsToLabelsRatios = [1, 2]
    
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
