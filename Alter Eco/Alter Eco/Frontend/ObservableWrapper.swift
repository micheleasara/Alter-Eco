import Foundation
import SwiftUI

/// Observable wrapper for a generic type.
public class Observable<T>: ObservableObject {
    /// The observed value in its unwrapped representation.
    @Published public var rawValue: T!
    public init(rawValue: T) {
        self.rawValue = rawValue
    }
}
