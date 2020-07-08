import SwiftUI

public struct PieChart: View {
    private let STARTING_ANGLE: Double = -90
    private let MAX_ANGLE: Double = 360
    @ObservedObject var model: PieChartViewModel
    
    public static func empty() -> some View {
        GeometryReader { geo in
            Circle()
            .fill(Color.green)
            .opacity(0.5)
            .frame(width: min(geo.size.height, geo.size.width), height: min(geo.size.height, geo.size.width), alignment: .center)
            .overlay(
                VStack {
                    Text("No data available... ")
                    .foregroundColor(Color.white)
                    .bold()
                    .font(.body)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.8)
                    Text("yet!")
                    .foregroundColor(Color.white)
                    .italic()
                    .font(.subheadline)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.8)
                }
            )
        }
    }
    
    public var body: some View {
        let slices = makeSlices()
        let legendNames = model.legendNames
        
        return GeometryReader { geo in
            VStack() {
                ZStack {
                    ForEach(0..<slices.count, id: \.self) { i in
                        slices[i]
                    }
                }.frame(height: 0.7*min(geo.size.height, geo.size.width)).padding(.bottom)
                
                VStack(spacing: 0) {
                    ForEach(0..<slices.count, id: \.self) { i in
                        HStack {
                            self.legendSquare(parentSize: geo.size, colour: slices[i].colour)
                            self.legendText(legendNames[i])
                            Spacer()
                            self.legendText(String(format: "%.1f%%", slices[i].percentage))
                        }
                    }
                }.frame(height: 0.2*min(geo.size.height, geo.size.width))
            }
        }
    }
    
    private func legendSquare(parentSize: CGSize, colour: Color) -> some View {
        let side = 0.03 * min(parentSize.height, parentSize.width)
        return Rectangle()
            .fill(colour)
            .frame(width: side, height: side)
    }
    
    private func makeSlices() -> [PieChartSlice] {
        var total = model.values.reduce(0.0, +)
        if total == 0 {
            total = 1
        }
        var currentAngle: Double = STARTING_ANGLE
        var slices: [PieChartSlice] = []
        
        for index in 0..<model.values.count {
            let ratio = model.values[index] / total
            let percentage = ratio * 100
            let endAngle = (ratio * MAX_ANGLE) + currentAngle
            let slice = PieChartSlice(colour: model.colours[index],
                                      start: .degrees(currentAngle),
                                      end: .degrees(endAngle),
                                      percentage: percentage,
                                      imageName: model.imageNames[index])
            slices.append(slice)
            currentAngle = endAngle
        }
        return slices
    }
    
    func legendText(_ text: String) -> some View {
        return Text(text)
        .allowsTightening(true)
        .font(.body)
        .minimumScaleFactor(0.8)
    }
}

public struct PieChartSlice: View {
    private(set) var colour: Color
    private(set) var start: Angle
    private(set) var end: Angle
    private(set) var percentage: Double
    private(set) var imageName: String
    @State private var shakeTaps: Int = 0
    @State private var showImage: Bool = true
    
    public var body: some View {
        GeometryReader { geo in
            self.drawSliceWithImage(rect: geo.frame(in: .local))
        }
    }
    
    func drawSliceWithImage(rect: CGRect) -> some View {
        let path = self.path(rect: rect)
        let offset = customOffset(radius: getRadius(size: rect.size))
        
        let angle = (end - start)
        let scale = CGFloat(min(0.35, angle.degrees/360))
        let minDim = min(rect.width, rect.height)
        let imgSize = scale * minDim
        let empty = UIImage(ciImage: CIImage.empty())
        let img = isSmallAngle() ? empty : (UIImage(named: imageName) ?? empty)
        return path.fill(colour)
            .overlay(
                Image(uiImage: img).resizable()
                    .frame(width: imgSize,
                           height: imgSize)
                    .offset(x: offset.x,
                            y: offset.y))
    }
    
    func isSmallAngle() -> Bool {
        return (end-start).degrees < 40
    }
    
    func getRadius(size: CGSize) -> CGFloat {
        return min(size.height, size.width) / 2
    }
    
    func path(rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height)/2
        let center = CGPoint(x: rect.midX,
                             y: rect.midY)
        var path = Path()
        
        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: start,
                    endAngle: end,
                    clockwise: false)
        return path
    }
    
    func customOffset(radius: CGFloat) -> CGPoint {
        let origin = CGPoint(x: 0, y: 0)
        let midAngle = start + Angle(degrees: abs(((start - end)/2).degrees))
        let mid = polarToCartesian(radius: radius, angle: midAngle)
        let x = (origin.x + mid.x) / 2
        let y = (origin.y + mid.y) / 2
        return CGPoint(x: x, y: y)
    }
    
    func polarToCartesian(radius: CGFloat, angle: Angle) -> CGPoint {
        let x = radius * CGFloat(cos(angle.radians))
        let y = radius * CGFloat(sin(angle.radians))
        return CGPoint(x: x, y: y)
        
    }
}

struct PieChart_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PieChart(model: FoodPieChartModel(DBMS: CoreDataManager())).previewLayout(PreviewLayout.sizeThatFits)
            PieChartSlice(colour: .red, start: .degrees(0), end: .degrees(180), percentage: 42, imageName: "meat").previewLayout(PreviewLayout.fixed(width: 300, height: 200))
            PieChart.empty().previewLayout(PreviewLayout.fixed(width: 300, height: 200))
        }
    }
}
