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

/// Represents a localized and identifiable error.
public class IdentifiableError: LocalizedError, Identifiable {
    public var errorDescription: String?
    
    public init(localizedDescription: String) {
        self.errorDescription = localizedDescription
    }
}

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

/// An observable object which only allows a fixed amount of numeric values.
public class NumbersFilter: ObservableObject {
    private let maxDigits: Int
    
    public init(maxDigits: Int) {
        self.maxDigits = maxDigits
    }
    
    @Published public var value = "" {
        didSet {
            var filtered = value.filter { $0.isNumber }
            
            if filtered.count >= maxDigits {
                filtered = String(filtered[..<filtered.index(filtered.startIndex, offsetBy: maxDigits)])
            }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}

public struct DBManagerKey: EnvironmentKey {
    public typealias Value = DBManager
    public static var defaultValue: DBManager = (UIApplication.shared.delegate as? AppDelegate)?.DBMS ?? CoreDataManager()
}

public extension EnvironmentValues {
    var DBMS: DBManager {
        get {
            return self[DBManagerKey.self]
        }
    }
}
