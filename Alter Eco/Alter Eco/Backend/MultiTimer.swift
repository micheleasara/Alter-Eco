import Foundation

protocol CountdownHandler {
    func start(key: String, interval: TimeInterval, block: @escaping () -> Void)
    func stop(_ key: String)
}

class MultiTimer : CountdownHandler {
    private var timers : [String: Timer] = [:]
    
    public func start(key: String, interval: TimeInterval, block: @escaping () -> Void) {
        stop(key)
        timers[key] = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(callback(timer:)), userInfo: block, repeats: false)
    }
    
    public func stop(_ key: String) {
        if let timer = timers[key] {
            timer.invalidate()
        }
    }
    
    @objc private func callback(timer: Timer) {
        let block = timer.userInfo as! () -> Void
        block()
    }
}
