import SwiftUI

public struct PieChart: View {
    private let STARTING_ANGLE: Double = -90
    private let MAX_ANGLE: Double = 360
    private(set) var model: PieChartModel
    
    public var body: some View {
        GeometryReader { geometry in
            self.draw(radius: 0.5 * min(geometry.size.width, geometry.size.height),
                      values: self.model.values)
        }
    }
    
    public func draw(radius: CGFloat, values: [Double]) -> some View {
        let slices = makeSlices(radius: radius, values: values)
        
        return ZStack {
            ForEach(0..<slices.count, id: \.self) { i in
                slices[i]
            }
        }
    }
    
    private func makeSlices(radius: CGFloat, values: [Double]) -> [PieChartSlice] {
        let total = values.reduce(0.0, +)
        var currentAngle: Double = STARTING_ANGLE
        var slices: [PieChartSlice] = []
        
        for index in 0..<values.count {
            let endAngle = (values[index] / total * MAX_ANGLE) + currentAngle
            let slice = PieChartSlice(radius: radius,
                                      colour: .red,
                                      start: .degrees(currentAngle),
                                      end: .degrees(endAngle))
            slices.append(slice)
            currentAngle = endAngle
        }
        return slices
    }
}

public struct PieChartSlice: View {
    @State private var showing: Bool = false
    private(set) var radius: CGFloat
    private(set) var colour: Color
    private(set) var start: Angle
    private(set) var end: Angle
    
    public var body: some View {
        
        path.fill(colour)
            .overlay(path.stroke(Color.white, lineWidth: 1))
            .scaleEffect(self.showing ? 1 : 0)
            .animation(
                Animation.spring(response: 0.5,
                                 dampingFraction: 0.5,
                                 blendDuration: 0.4))
            .onAppear() {
                self.showing = true
        }
    }
    
    public var path: Path {
        let centerX = radius
        let centerY = radius
        
        var path = Path()
        
        path.move(to: CGPoint(x: centerX, y: centerY))
        path.addArc(center: CGPoint(x: centerX, y: centerY),
                    radius: radius,
                    startAngle: start,
                    endAngle: end,
                    clockwise: false)
        return path
    }
}

public class PieChartModel: ObservableObject {
    @Published public var values: [Double]!
    
    public init(data: [Double]) {
        self.values = data
    }
}

struct PieChart_Previews: PreviewProvider {
    static var previews: some View {
        PieChart(model: PieChartModel(data: [10, 2, 3]))
    }
}
