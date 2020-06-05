import Foundation
import SwiftUI

/// Observable wrapper for a generic type.
public class Observable<T>: ObservableObject {
    /// The observed value in its unwrapped representation.
    public var rawValue: T! {
        willSet {
            // using willSet with objectWillChange is analogous to @Published
            objectWillChange.send()
            // but it allows more flexibility, such as making a call
            valueChangeCallback(newValue)
        }
    }
    
    private var valueChangeCallback: (_ newValue: T) -> Void = {_  in }
    
    public init(rawValue: T) {
        self.rawValue = rawValue
    }
    
    /// Sets a callback function for when the wrapped value changes. The new value is passed as an argument.
    public func setValueChangeCallback(callback: @escaping (T) -> Void) {
        valueChangeCallback = callback
    }
}
