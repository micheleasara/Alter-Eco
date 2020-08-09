import Foundation
import SwiftUI

/// View model for the pie chart representing transportation data.
public class TransportPieChartViewModel: PieChartModel {
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
        updateUpTo(Date())
    }
    
    /// Updates the chart up to the date given.
    public func updateUpTo(_ date: Date) {
        let now = date
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
                    imageNames.append(TransportPieChartViewModel.MOTION_TO_IMAGE[type] ?? "Image not found")
                    legendNames.append(TransportPieChartViewModel.MOTION_TO_LEGEND[type] ?? "Legend not found")
                    colours.append(TransportPieChartViewModel.MOTION_TO_COLOUR[type] ?? .red)
                }
            }
        }
        update(values: values, imageNames: imageNames, colours: colours, legendNames: legendNames)
    }
}
