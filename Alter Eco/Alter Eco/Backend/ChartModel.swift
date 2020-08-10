import Foundation
import SwiftUI

/// Represents an updatable model for a chart.
public protocol ChartModel {
    /// Updates the model internal data up to the date provided.
    func updateUpTo(_ date: Date)
}

/// View model for a pie chart. All properties should be set to an appropriate value or a default appeareance will be generated.
public class PieChartViewModel: ObservableObject {
    @Published public var values: [Double] = []
    @Published public var imageNames: [String] = [""]
    @Published public var colours: [Color] = [.primary]
    @Published public var legendNames: [String] = [""]
    
    /// Updates and publishes all given arguments.
    public func update(values: [Double], imageNames: [String],
                  colours: [Color], legendNames: [String]) {
        self.values = values
        self.imageNames = imageNames
        self.colours = colours
        self.legendNames = legendNames
    }
}

/// Represents the model for a pie chart. All the properties of the view model should be initialised and updated with a call to updateUpTo.
public typealias PieChartModel = PieChartViewModel & ChartModel
