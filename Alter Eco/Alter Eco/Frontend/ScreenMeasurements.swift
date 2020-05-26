import Foundation
import SwiftUI

public class ScreenMeasurements: ObservableObject {
    @Published var longitudinal: CGFloat
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
