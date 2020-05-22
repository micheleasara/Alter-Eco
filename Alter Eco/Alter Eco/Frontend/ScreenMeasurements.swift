import Foundation
import SwiftUI

class ScreenMeasurements: ObservableObject {
    @Published var broadcastedHeight: CGFloat = CGFloat(UIScreen.main.bounds.height)
    @Published var broadcastedWidth: CGFloat = CGFloat(UIScreen.main.bounds.width)
}
