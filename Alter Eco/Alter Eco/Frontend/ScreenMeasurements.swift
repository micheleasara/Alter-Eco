import Foundation
import SwiftUI

class ScreenMeasurements: ObservableObject {
    @Published var broadcastedHeight: Float = Float(UIScreen.main.bounds.height)
    @Published var broadcastedWidth: Float = Float(UIScreen.main.bounds.width)
}
