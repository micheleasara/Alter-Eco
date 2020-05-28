import Foundation
import Network

class WifiStatusMonitor: ObservableObject {
    @Published var isConnected: Bool = false
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    let queue = DispatchQueue.global(qos: .background)
    
    func startMonitoring() {
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
