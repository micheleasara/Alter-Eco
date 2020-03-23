import Foundation

public class TrackingData : ObservableObject {
    @Published var distance: Double = 0
    @Published var time: Double = 0
    @Published var speed: Double = 0
    @Published var transportMode: String = "Not automotive"
    @Published var station : String = "Not in a tube station"
}

