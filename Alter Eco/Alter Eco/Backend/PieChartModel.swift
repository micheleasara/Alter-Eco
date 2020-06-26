import Foundation
import SwiftUI

public protocol ChartModel {
    func updateUpTo(_ date: Date)
}

public class PieChartViewModel: ObservableObject {
    @Published public var values: [Double]
    @Published public var imageNames: [String]
    @Published public var colours: [Color]
    @Published public var legendNames: [String]
    
    fileprivate init(values: [Double] = [0], imageNames: [String] = [""],
                  colours: [Color] = [.red], legendNames: [String] = [""]) {
        self.values = values
        self.imageNames = imageNames
        self.colours = colours
        self.legendNames = legendNames
    }
}

public class TransportPieChartModel: PieChartViewModel {
    private static let MOTION_TO_IMAGE:
        [MeasuredActivity.MotionType:String] = [.car:"car", .plane:"plane", .train:"train"]
    private static let MOTION_TO_LEGEND:
    [MeasuredActivity.MotionType:String] = [.car:"Car and bus", .plane:"Plane", .train:"Train and subway"]
    private static let MOTION_TO_COLOUR:
        [MeasuredActivity.MotionType:Color] = [.car:.yellow, .plane:.red, .train:.orange]
    private var DBMS: DBManager!
    
    public init(DBMS: DBManager) {
        self.DBMS = DBMS
        super.init()
        update()
    }
    
    public func update() {
        let now = Date().toLocalTime()
        var values: [Double] = []
        var imageNames: [String] = []
        var colours: [Color] = []
        var legendNames: [String] = []
        
        if let origin = try? DBMS.getFirstDate() {
            let interval = now.timeIntervalSince(origin)
            for type in MeasuredActivity.MotionType.allCases {
                if type.isPolluting() {
                    let carbon = (try? DBMS.carbonWithinInterval(motionType: type, from: origin, interval: interval)) ?? 0
                    values.append(carbon)
                    imageNames.append(TransportPieChartModel.MOTION_TO_IMAGE[type] ?? "TransportPieChartModel: image not found")
                    legendNames.append(TransportPieChartModel.MOTION_TO_LEGEND[type] ?? "TransportPieChartModel: legend not found")
                    colours.append(TransportPieChartModel.MOTION_TO_COLOUR[type] ?? .purple)
                }
            }
        }
        self.values = values
        self.imageNames = imageNames
        self.colours = colours
        self.legendNames = legendNames
    }
}

public class FoodPieChartModel: PieChartViewModel {
    public init() {
        super.init(values: [90, 100, 20, 35],
                   imageNames: ["meat", "dairies", "vegetable", "fast-food"],
                   colours: [.red, .yellow, .green, .blue],
                   legendNames: ["Meat and seafood",
                                 "Dairies and eggs",
                                 "Veggies, fruits and legumes",
                                 "Snacks, soft drinks and others"])
    }
}
