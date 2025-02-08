import Combine
import SwiftUI

/// A property wrapper for a value in user defaults.
@propertyWrapper
public struct UserDefault<Value, Stored: UserDefaultsStorable>: DynamicProperty {

    @State private var value: Value

    private let key: UserDefaultKey<Value, Stored>
    private let defaults: UserDefaults

    /// Creates a dynamic UserDefault property wrapper to access the value for
    /// the given key.
    ///
    /// - Parameters:
    ///   - key: The key for the desired value
    ///   - defaults: The user defaults storage to access.
    public init(_ key: UserDefaultKey<Value, Stored>, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
        self._value = State(initialValue: key.default)
    }

    /// The value stored in user defaults for the given key.
    public var wrappedValue: Value {
        get { value }
        nonmutating set {
            defaults.set(newValue, for: key)
            value = newValue
        }
    }

    public var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}
