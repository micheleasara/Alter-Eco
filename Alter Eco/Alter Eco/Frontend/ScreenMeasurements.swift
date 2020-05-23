import Foundation
import SwiftUI

class ScreenMeasurements: ObservableObject {
    @Published var height: CGFloat = CGFloat(UIScreen.main.bounds.height)
    @Published var width: CGFloat = CGFloat(UIScreen.main.bounds.width)
}
