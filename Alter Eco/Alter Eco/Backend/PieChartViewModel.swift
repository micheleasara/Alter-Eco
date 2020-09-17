import Foundation
import SwiftUI

/// View model for a pie chart. All properties should be set to an appropriate value or a default appeareance will be generated.
public class PieChartViewModel: ObservableObject {
    @Published public var values: [Double] = []
    @Published public var imageNames: [String] = [""]
    @Published public var colours: [Color] = [.primary]
    @Published public var legendNames: [String] = [""]
    
    internal init() {}
    
    /// Updates and publishes all given arguments.
    public func update(values: [Double], imageNames: [String],
                  colours: [Color], legendNames: [String]) {
        self.values = values
        self.imageNames = imageNames
        self.colours = colours
        self.legendNames = legendNames
    }
}
