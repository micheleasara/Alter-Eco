import SwiftUI

/// Represents a bar chart that can display information when a bar is clicked.
/// To avoid displaying any information, provide an empty string.
public struct BarChart: View {
    /// Collection of values displayed in the chart.
    public let values: [Double]
    /// Collection of labels for the x-axis.
    public let xLabels: [String]
    /// Collection of information displayed when tapping on a bar.
    public let infoOnBarTap: [String]
    /// The colour of each bar in the chart.
    public let colour: Color
    public let yAxisTicksCount: Int
    /// Amount of relative space used for spacing among bars.
    static let SPACING_RATIO: CGFloat = 0.2
    /// Amount of relative space used for all bars widths.
    static let DRAWING_RATIO: CGFloat = 1 - SPACING_RATIO
    /// Absolute distance of the y-axis from the chart.
    static let Y_AXIS_DISTANCE_FROM_CHART: CGFloat = 6
    /// Absolute height of the x-axis.
    static let xAxisHeight = 2*BarChart.Y_AXIS_DISTANCE_FROM_CHART
    /// Absolute width of the y-axis.
    static let yAxisWidth = 2*BarChart.Y_AXIS_DISTANCE_FROM_CHART
    /// Defines the minimum amount of space between the chart height and
    /// the top y-axis tick required for the latter to appear (for aesthetics).
    private static let MIN_SPACE_FOR_FINAL_TICK_TO_APPEAR: CGFloat = 10
    private let ANSWER_TO_EVERYTHING: Double = 42
    
    public var body: some View {
        GeometryReader { geo in
            // In order to align both the x-axis and the y-axis with the chart we use offsets
            // So, to keep the chart within the parent view, the chart is framed in a smaller box
            self.outOfBoundsChart
                .frame(width: geo.size.width - 2*BarChart.yAxisWidth - BarChart.Y_AXIS_DISTANCE_FROM_CHART,
                       height: geo.size.height - BarChart.xAxisHeight)
        }
    }
    
    private var outOfBoundsChart: some View {
        GeometryReader { geometry in
            ZStack (alignment: .bottomLeading) {
                ZStack(alignment: .bottomLeading) {
                    self.bars.frame(width: geometry.size.width, height: geometry.size.height)
                    self.grid.frame(width: geometry.size.width, height: geometry.size.height)
                }
                .offset(x: BarChart.yAxisWidth)
                
                self.xAxis
                    .frame(width: geometry.size.width, height: BarChart.xAxisHeight)
                    .offset(x: BarChart.yAxisWidth, y: BarChart.xAxisHeight)

                self.yAxis
                    .frame(width: BarChart.yAxisWidth, height: geometry.size.height, alignment: .bottom)
                    .offset(x: -BarChart.Y_AXIS_DISTANCE_FROM_CHART)
            }
            .offset(x: BarChart.yAxisWidth)
        }
    }
    
    private var grid: some View {
        VStack(spacing: 0) {
            verticalGridlines.overlay(horizontalGridlines)
            Divider()
        }
            
    }
    
    private var verticalGridlines: some View {
        let numGridlines = CGFloat(self.xLabels.count)
        
        return GeometryReader { geo in
        HStack(spacing: 0) {
            ForEach(self.xLabels, id: \.self) { _ in
                Divider().frame(width: geo.size.width/numGridlines, height: geo.size.height, alignment: .bottomLeading)
                }
            }
        }
    }
    
    private var horizontalGridlines: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                if geo.size.height - self.yAxisSpacing(chartHeight: geo.size.height)*CGFloat(self.yAxisTicksCount) >= BarChart.MIN_SPACE_FOR_FINAL_TICK_TO_APPEAR {
                    Divider().frame(width: geo.size.width,
                    height: self.yAxisSpacing(chartHeight: geo.size.height), alignment: .top)
                }
                // line of graph frame
                ForEach(1..<self.yAxisTicksCount, id: \.self) {_ in
                    Divider().frame(width: geo.size.width,
                                    height: self.yAxisSpacing(chartHeight: geo.size.height), alignment: .top)
                }
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
        }
    }
    
    private var bars: some View {
        let barCount = CGFloat(values.count)

        return GeometryReader { geo in
            HStack(alignment:.bottom, spacing: BarChart.SPACING_RATIO * geo.size.width / barCount) {
                ForEach(0..<self.values.count, id: \.self) { i in
                    BarWithInfo(size:
                        CGSize(width: geo.size.width * BarChart.DRAWING_RATIO / barCount,
                               height: geo.size.height * CGFloat(self.values[i])/CGFloat(self.maxBarValue)),
                                colour: self.colour,
                                information: self.infoOnBarTap[i])
                }
            }
        }
    }
    
    private var yAxis: some View {
        return GeometryReader { geo in
            VStack(spacing: self.yAxisSpacing(chartHeight: geo.size.height)/2) {
                
                if geo.size.height - self.yAxisSpacing(chartHeight: geo.size.height)*CGFloat(self.yAxisTicksCount) > BarChart.MIN_SPACE_FOR_FINAL_TICK_TO_APPEAR {
                    self.axisLabel(text: String(format: "%g", Double(self.yAxisTicksCount) * self.yAxisInterval))
                    .frame(width: geo.size.width,
                           height: self.yAxisSpacing(chartHeight: geo.size.height)/2,
                           alignment:.bottomTrailing)
                }
                
                // reversed as it goes from top to bottom
                ForEach((0..<self.yAxisTicksCount).reversed(), id: \.self) { i in
                    self.axisLabel(text: String(format: "%g", Double(i) * self.yAxisInterval))
                        .frame(width: geo.size.width,
                               height: self.yAxisSpacing(chartHeight: geo.size.height)/2,
                               alignment:.bottomTrailing)
                }
            }.frame(height: geo.size.height, alignment: .bottomTrailing)
        }
    }
    
    private var yAxisInterval: Double {
        var interval = maxBarValue / Double(yAxisTicksCount)
        if interval >= 1 {
            interval.round(.down)
        } else {
            // if too small to be rounded down (as it would give 0)
            // keep up to 2 significant digits
            interval = (interval / 0.01).rounded(.up) * 0.01
        }
        return interval
    }
    
    private func yAxisSpacing(chartHeight: CGFloat) -> CGFloat {
        return CGFloat(yAxisInterval)/CGFloat(maxBarValue) * chartHeight
    }
    
    private var maxBarValue: Double {
        let ticksCount = Double(yAxisTicksCount)
        var max = values.max() ?? ANSWER_TO_EVERYTHING * ticksCount
        if max == 0 {
            max = ANSWER_TO_EVERYTHING * ticksCount
        }
        return max
    }
    
    private var xAxis : some View {
        let ticksCount = CGFloat(xLabels.count)
        return GeometryReader { geo in
            HStack(alignment:.bottom, spacing: 0) {
                ForEach(self.xLabels, id: \.self) { label in
                    self.axisLabel(text: label)
                        .frame(width: geo.size.width/ticksCount,
                               height: geo.size.height, alignment: .bottomLeading)
                }
            }
        }
    }
    
    private func axisLabel(text: String) -> some View {
        return Text(text)
            .allowsTightening(true)
            .font(.system( size: 10))
            .minimumScaleFactor(0.01)
            .lineLimit(1)
            .fixedSize()
    }
}

struct BarChart_Previews: PreviewProvider {

    static let barsToLabelsRatios = [1, 2]
    
    static var previews: some View {
        return Group {
            BarChart(values: [0,0,0,0], xLabels: ["a","b","c","d"], infoOnBarTap: ["","","",""], colour: Color.green, yAxisTicksCount: 4).padding()
                .previewLayout(PreviewLayout.fixed(width: 300, height: 160))
            .previewDisplayName("0-valued, 4 y-ticks")
            
            ForEach(barsToLabelsRatios, id: \.self) { r in
                previewWithRatio(numBars: 12, ratio: r)
                    .previewLayout(PreviewLayout.fixed(width: 300, height: 160))
                .previewDisplayName("Bars to labels ratio: " + String(r))
            }
            
            previewWithRatio(numBars: 5, ratio: 1).environment(\.colorScheme, .dark).previewLayout(PreviewLayout.fixed(width: 300, height: 160)).background(Color.black).previewDisplayName("Dark mode")
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
        
        return BarChart(values: testData, xLabels: labels, infoOnBarTap: infoBarsOnTap, colour: Color.green, yAxisTicksCount: 5).padding()
    }
}
