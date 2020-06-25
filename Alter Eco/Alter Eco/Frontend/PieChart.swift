import SwiftUI

public struct PieChart: View {
    private let STARTING_ANGLE: Double = -90
    private let MAX_ANGLE: Double = 360
    private(set) var model: PieChartModel
    
    public var body: some View {
        let slices = makeSlices()
        let legendNames = model.legendNames
        
        return GeometryReader { geo in
            VStack() {
                ZStack {
                    ForEach(0..<slices.count, id: \.self) { i in
                        slices[i]
                    }
                }.frame(height: 0.8*geo.size.height)
                
                VStack(spacing: 3) {
                    ForEach(0..<slices.count, id: \.self) { i in
                        HStack {
                            self.legendSquare(parentSize: geo.size, colour: slices[i].colour)
                            self.legendText(legendNames[i])
                            Spacer()
                            self.legendText(String(format: "%.1f%%", slices[i].percentage))
                        }
                    }
                }
                .frame(height: 0.2*geo.size.height)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.primary, lineWidth: 1)
                )
            }
        }
    }
    
    private func legendSquare(parentSize: CGSize, colour: Color) -> some View {
        let side = min(parentSize.height, parentSize.width)/20
        return Rectangle()
            .fill(colour)
            .frame(width: side, height: side)
    }
    
    private func makeSlices() -> [PieChartSlice] {
        let total = model.values.reduce(0.0, +)
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
        .font(.system(size: 15))
        .minimumScaleFactor(0.01)
        .lineLimit(1)
    }
}

public struct PieChartSlice: View {
    //private(set) var radius: CGFloat
    private(set) var colour: Color
    private(set) var start: Angle
    private(set) var end: Angle
    private(set) var percentage: Double
    private(set) var imageName: String
    @State private var shakeTaps: Int = 0
    @State private var showImage: Bool = true
    @State private var workItem: DispatchWorkItem?
    
    public var body: some View {
        GeometryReader { geo in
            self.drawSliceWithImage(rect: geo.frame(in: .local))
        }
    }
    
    func drawSliceWithImage(rect: CGRect) -> some View {
        let path = self.path(rect: rect)
        let offset = customOffset(radius: getRadius(size: rect.size))
        
        let angle = (end - start)
        let scale = CGFloat(0.5 * min(0.6, angle.degrees/360))
        let minDim = min(rect.width, rect.height)
        let imgSize = scale * minDim
        let img = isSmallAngle() ? UIImage(ciImage: CIImage.empty()) : UIImage(named: imageName)!
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
        let x = (origin.x + 1.3*mid.x) / 2
        let y = (origin.y + 1.3*mid.y) / 2
        return CGPoint(x: x, y: y)
    }
    
    func polarToCartesian(radius: CGFloat, angle: Angle) -> CGPoint {
        let x = radius * CGFloat(cos(angle.radians))
        let y = radius * CGFloat(sin(angle.radians))
        return CGPoint(x: x, y: y)
        
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            0,
            y: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))))
    }
}

public class PieChartModel: ObservableObject {
    @Published private(set) public var values: [Double]
    @Published private(set) public var imageNames: [String]
    @Published private(set) public var colours: [Color]
    @Published private(set) public var legendNames: [String]
    
    internal init(values: [Double], imageNames: [String],
                  colours: [Color], legendNames: [String]) {
        self.values = values
        self.imageNames = imageNames
        self.colours = colours
        self.legendNames = legendNames
    }
}

public class FoodPieChartModel: PieChartModel {

    public init() {
        super.init(values: [90, 45, 20, 35],
                   imageNames: ["meat", "dairies", "vegetable", "fast-food"],
                   colours: [.red, .yellow, .green, .blue],
                   legendNames: ["Meat and fish",
                                 "Dairies and eggs",
                                 "Veggies, fruits and legumes",
                                 "Snacks, soft drinks and others"])
    }
}

struct PieChart_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PieChart(model: FoodPieChartModel())
                .frame(width: 300, height: 300)
            PieChartSlice(colour: .red, start: .degrees(0), end: .degrees(180), percentage: 42, imageName: "meat")
        }
    }
}
