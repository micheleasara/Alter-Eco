import Foundation

/// An interface which allows to handle multiple countdowns.
public protocol CountdownHandler {
    /**
     Starts a countdown.
     - Parameters key: identifier for the countdown.
     - Parameters interval: how long the countdown will be.
     - Parameters block: procedure called at the end of the countdown.
     */
    func start(key: String, interval: TimeInterval, block: @escaping () -> Void)
    
    /**
    Stops a countdown.
    - Parameters key: identifier for the countdown.
     */
    func stop(_ key: String)
}

/// Represents an object associating keys to specific timers.
public class MultiTimer : CountdownHandler {
    private var timers : [String: Timer] = [:]
    
    /**
    Starts a countdown.
    - Parameters key: identifier for the countdown.
    - Parameters interval: how long the countdown will be.
    - Parameters block: procedure called at the end of the countdown.
    - Remark: if start is called with a key already associated to a countdown, the latter is stopped and restarted.
    */
    public func start(key: String, interval: TimeInterval, block: @escaping () -> Void) {
        stop(key)
        timers[key] = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(callback(timer:)), userInfo: block, repeats: false)
    }
    
    /**
    Stops a countdown.
    - Parameters key: identifier for the countdown.
    - Remark: if no countdown is associated with the given key, nothing happens.
     */
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
