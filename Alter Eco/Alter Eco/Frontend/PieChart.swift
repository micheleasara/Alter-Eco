import SwiftUI

public struct PieChart: View {
    private let STARTING_ANGLE: Double = -90
    private let MAX_ANGLE: Double = 360
    private(set) var model: PieChartModel
    public var body: some View {
        let slices = makeSlices()
        
        return ZStack {
            ForEach(0..<slices.count, id: \.self) { i in
                slices[i]
            }
        }
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
                                      message: String(format: "%.1f%%", percentage),
                                      percentage: percentage,
                                      imageName: model.imageNames[index])
            slices.append(slice)
            currentAngle = endAngle
        }
        return slices
    }
}

public struct PieChartSlice: View {
    //private(set) var radius: CGFloat
    private(set) var colour: Color
    private(set) var start: Angle
    private(set) var end: Angle
    private(set) var message: String
    private(set) var percentage: Double
    private(set) var imageName: String
    @State private var shakeTaps: Int = 0
    @State private var showImage: Bool = true
    @State private var workItem: DispatchWorkItem?
    @State private var showAlert: Bool = false
    
    public var body: some View {
        GeometryReader { geo in
            
            Group {
                if self.showImage {
                    self.drawSliceWithImage(rect: geo.frame(in: .local))
                } else {
                    self.drawSliceWithPercentage(rect: geo.frame(in: .local))
                }
            }
            // shake animation and change of item on top
            .modifier(Shake(animatableData: CGFloat(self.shakeTaps)))
                .animation(.linear(duration: 0.5))
            .onTapGesture {
                withAnimation(.default) {
                    self.shakeTaps = (self.shakeTaps + 1) % 2
                }
                if let workItem = self.workItem {
                    // if not nil, another worker might be running
                    workItem.cancel()
                }
                self.workItem = DispatchWorkItem { self.showImage.toggle()
                    if self.isSmallAngle() {
                        self.showAlert = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: self.workItem!)
            }
            // for small angles only
            .alert(isPresented: self.$showAlert) {
                Alert(title: Text("Info"), message: Text(self.message), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func drawSliceWithImage(rect: CGRect) -> some View {
        let path = self.path(rect: rect)
        let offset = customOffset(radius: getRadius(size: rect.size))
        
        let angle = (end - start)
        let scale = CGFloat(0.5 * min(0.5, angle.degrees/360))
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
    
    func drawSliceWithPercentage(rect: CGRect) -> some View {
        let radius = getRadius(size: rect.size)
        let path = self.path(rect: rect)
        let offset = customOffset(radius: radius)
        let txt = isSmallAngle() ? "" : String(format: "%.1f", percentage)
        let txtSize = 0.4*radius
        return path.fill(colour)
            .overlay(
                Text(txt)
                .allowsTightening(true)
                .font(.system(size: 15))
                .minimumScaleFactor(0.01)
                .lineLimit(1)
                .frame(width: txtSize, height: txtSize)
                .offset(x: offset.x, y: offset.y))
    }
    
    func isSmallAngle() -> Bool {
        return (end-start).degrees < 25
    }
    
    func getRadius(size: CGSize) -> CGFloat {
        return min(size.height, size.width) / 2
    }
    
    func chordLength(radius: CGFloat, angle: Angle) -> CGFloat {
        return 2 * radius * CGFloat(sin(angle.radians/2))
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
        let x = (origin.x + 1.2*mid.x) / 2
        let y = (origin.y + 1.2*mid.y) / 2
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
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

public class PieChartModel: ObservableObject {
    @Published private(set) public var values: [Double]
    @Published private(set) public var imageNames: [String]
    @Published private(set) public var colours: [Color]
    
    internal init(values: [Double], imageNames: [String], colours: [Color]) {
        self.values = values
        self.imageNames = imageNames
        self.colours = colours
    }
}

public class FoodPieChartModel: PieChartModel {

    public init() {
        super.init(values: [40, 20, 18, 27],
                   imageNames: ["meat", "dairies", "vegetable", "fast-food"],
                   colours: [.red, .yellow, .green, .blue])
    }
}

struct PieChart_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PieChart(model: FoodPieChartModel())
                .frame(width: 300, height: 300)
            PieChartSlice(colour: .red, start: .degrees(0), end: .degrees(30), message: "Test message", percentage: 42, imageName: "meat")
        }
    }
}
