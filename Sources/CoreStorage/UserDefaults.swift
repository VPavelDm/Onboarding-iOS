import Foundation

/// Represents types that can be stored in `UserDefaults`.
public protocol UserDefaultsStorable {}
extension Array: UserDefaultsStorable where Element: UserDefaultsStorable {}
extension Bool: UserDefaultsStorable {}
extension Data: UserDefaultsStorable {}
extension Date: UserDefaultsStorable {}
extension Dictionary: UserDefaultsStorable where Key == String, Value: UserDefaultsStorable {}
extension Int: UserDefaultsStorable {}
extension Optional: UserDefaultsStorable where Wrapped: UserDefaultsStorable {}
extension String: UserDefaultsStorable {}
extension URL: UserDefaultsStorable {}

struct NilFound: Error {}

/// Represents a key used for `UserDefaults`.
///
/// This contains the expected type of the value and the storage, which allows
/// generic additions to be added to `UserDefaults`
public struct UserDefaultKey<Value, Stored: UserDefaultsStorable> {

    public let name: String
    public let `default`: Value
    public let encode: (Value) throws -> Stored
    public let decode: (Stored) throws -> Value

    public init(
        name: String,
        default: Value,
        encode: @escaping (Value) throws -> Stored,
        decode: @escaping (Stored) throws -> Value
    ) {
        self.name = name
        self.default = `default`
        self.encode = encode
        self.decode = decode
    }

    public init<V>(
        name: String,
        encode: @escaping (V) throws -> Stored,
        decode: @escaping (Stored) throws -> V
    ) where Value == V? {
        self.init(
            name: name,
            default: nil,
            encode: { value in
                guard let value = value else { throw NilFound() }
                return try encode(value)
            },
            decode: decode
        )
    }

    public init(name: String, default: Value) where Value == Stored {
        self.init(name: name, default: `default`, encode: { $0 }, decode: { $0 })
    }

    /// Create a key for an optional value.
    public init<T>(name: String) where Value == T?, Value == Stored {
        self.init(name: name, default: nil)
    }
}

extension UserDefaultKey where Stored == Data {

    /// Stores a value using a json encoder and decoder.
    ///
    /// The `encode` and `decode` functions here should conert between the
    /// desired output value type and a storage type. Generally model types
    /// should not be stored directly, so that they can be freely modified
    /// without affecting stored values, as the conversion methods will handle
    /// changes to the structure.
    ///
    /// - Parameters:
    ///   - name: The name of the key to use.
    ///   - default: The default value to use.
    ///   - encode: Convert the `Value` into a `CodableValue`.
    ///   - decode: Convert the `CodableValue` into a `Value`.
    /// - Returns: A user defaults key.
    public static func json<CodableValue>(
        name: String,
        default: Value,
        encode: @escaping (Value) throws -> CodableValue,
        decode: @escaping (CodableValue) throws -> Value
    ) -> UserDefaultKey where CodableValue: Codable {
        UserDefaultKey(
            name: name,
            default: `default`,
            encode: { value in
                let codable = try encode(value)
                return try JSONEncoder().encode(codable)
            },
            decode: { data in
                let codable = try JSONDecoder().decode(CodableValue.self, from: data)
                return try decode(codable)
            }
        )
    }

    public static func json<V, CodableValue>(
        name: String,
        encode: @escaping (V) throws -> CodableValue,
        decode: @escaping (CodableValue) throws -> V
    ) -> UserDefaultKey where CodableValue: Codable, Value == V? {
        UserDefaultKey(
            name: name,
            encode: { value in
                let codable = try encode(value)
                return try JSONEncoder().encode(codable)
            },
            decode: { data in
                let codable = try JSONDecoder().decode(CodableValue.self, from: data)
                return try decode(codable)
            })
    }
}

extension UserDefaultKey where Value: Codable, Stored == Data {

    public static func json(
        name: String,
        default: Value
    ) -> UserDefaultKey {
        UserDefaultKey(
            name: name,
            default: `default`,
            encode: { value in
                try JSONEncoder().encode(value)
            },
            decode: { data in
                try JSONDecoder().decode(Value.self, from: data)
            }
        )
    }

}

struct UnexpectedType: Error {
    let value: Any?
}

extension CoreStorage.UserDefaultKey where Stored == Data {

    /// This mimics the way the `PersistanceService` code was implementing
    /// saving to the keychain.
    ///
    /// This should not be used going forward, it is preferable to use
    /// ``json(name:encode:decode)`` instead.
    ///
    /// - Parameters:
    ///   - name: The name of the key to use.
    ///   - encode: Convert the `Value` into a `UserDefaultsStorable`.
    ///   - decode: Convert the `UserDefaultsStorable` into a `Value`.
    /// - Returns: A user defaults key.
    public static func keyedArchiver<V, RootObject>(
        name: String,
        encode: @escaping (V) throws -> RootObject,
        decode: @escaping (RootObject) throws -> V
    ) -> Self where Value == V?, RootObject: UserDefaultsStorable, RootObject: NSCoding, RootObject: NSObject {
        Self(
            name: name,
            encode: { value in
                let root = try encode(value)
                return try NSKeyedArchiver.archivedData(withRootObject: root, requiringSecureCoding: false)
            },
            decode: { data in
                let unarchived = try NSKeyedUnarchiver.unarchivedObject(ofClass: RootObject.self, from: data)
                guard let unarchived else { throw UnexpectedType(value: unarchived) }
                return try decode(unarchived)
            })
    }

    public static func keyedArchiver<RootObject>(
        name: String,
        default: Value,
        encode: @escaping (Value) throws -> RootObject,
        decode: @escaping (RootObject) throws -> Value
    ) -> Self where RootObject: UserDefaultsStorable, RootObject: NSCoding, RootObject: NSObject {
        Self(
            name: name,
            default: `default`,
            encode: { value in
                let root = try encode(value)
                return try NSKeyedArchiver.archivedData(withRootObject: root, requiringSecureCoding: false)
            },
            decode: { data in
                let unarchived = try NSKeyedUnarchiver.unarchivedObject(ofClass: RootObject.self, from: data)
                guard let unarchived else { throw UnexpectedType(value: unarchived) }
                return try decode(unarchived)
            })
    }
}

// MARK: - UserDefaults Access

extension UserDefaults {

    /// Returns the value associated with the specified key.
    ///
    /// - Parameter key: A key in the current user‘s defaults database.
    /// - Returns: The value associated with the specified key, or the key's
    ///            default if the value was not found.
    public func value<Value, Stored>(for key: UserDefaultKey<Value, Stored>) -> Value {
        guard
            let stored = object(forKey: key.name) as? Stored,
            let value = try? key.decode(stored)
        else {
            return key.default
        }
        return value
    }

    /// Returns the url associated with the specified key.
    ///
    /// - Parameter key: A key in the current user‘s defaults database.
    /// - Returns: The url associated with the specified key, or the key's
    ///            default if the value was not found.
    public func value<Value>(for key: UserDefaultKey<Value, URL>) -> Value {
        guard
            let stored = url(forKey: key.name),
            let value = try? key.decode(stored)
        else {
            return key.default
        }
        return value
    }

    /// Sets the value of the specified default key.
    ///
    /// The value parameter can be only property list objects. For arrays and
    /// dictionaries, their contents must be property list objects.
    ///
    /// - Parameters:
    ///   - value: The value to store in the defaults database.
    ///   - key: The key with which to associate the value.
    public func set<Value, Stored>(_ value: Value, for key: UserDefaultKey<Value, Stored>) {
        guard let stored = try? key.encode(value) else { return }
        set(stored, forKey: key.name)
    }

    /// Sets the value of the specified default key.
    ///
    /// The value parameter can be only property list objects. For arrays and
    /// dictionaries, their contents must be property list objects.
    ///
    /// - Parameters:
    ///   - value: The value to store in the defaults database.
    ///   - key: The key with which to associate the value.
    public func set<Value, Stored>(_ value: Value?, for key: UserDefaultKey<Value?, Stored>) {

        // Note this is needed to prevent a crash in UserDefaults when setting a
        // nil value. This will override the previous set method when the Key's
        // Value is optional.

        guard let value = value else {
            removeValue(for: key)
            return
        }

        guard let stored = try? key.encode(value) else { return }
        set(stored, forKey: key.name)
    }

    /// Removes the value of the specified key.
    ///
    /// - Parameter key: The key whose value you want to remove.
    public func removeValue<Value, Stored>(for key: UserDefaultKey<Value, Stored>) {
        removeObject(forKey: key.name)
    }
}
