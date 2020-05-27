import Foundation
import SwiftUI

/// Contains information about the major and minor axis of the screen.
public class ScreenMeasurements: ObservableObject {
    /// The length of the major axis of the screen.
    @Published var longitudinal: CGFloat
    /// The length of the minor axis of the screen.
    @Published var trasversal: CGFloat
    
    public init() {
        if UIScreen.main.bounds.height >= UIScreen.main.bounds.width {
            longitudinal = UIScreen.main.bounds.height
            trasversal = UIScreen.main.bounds.width
        } else {
            longitudinal = UIScreen.main.bounds.width
            trasversal = UIScreen.main.bounds.height
        }
    }
}
