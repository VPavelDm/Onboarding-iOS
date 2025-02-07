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
public struct UserDefaultsKey<Value, Stored: UserDefaultsStorable> {

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
            decode: decode)
    }

    public init(name: String, default: Value) where Value == Stored {
        self.init(name: name, default: `default`, encode: { $0 }, decode: { $0 })
    }

    /// Create a key for an optional value.
    public init<T>(name: String) where Value == T?, Value == Stored {
        self.init(name: name, default: nil)
    }
}

extension UserDefaultsKey where Stored == Data {

    // swiftlint:disable opening_brace
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
    ) -> UserDefaultsKey
    where
        CodableValue: Codable
    {
        UserDefaultsKey(
            name: name,
            default: `default`,
            encode: { value in
                let codable = try encode(value)
                return try JSONEncoder().encode(codable)
            },
            decode: { data in
                let codable = try JSONDecoder().decode(CodableValue.self, from: data)
                return try decode(codable)
            })
    }

    public static func json<V, CodableValue>(
        name: String,
        encode: @escaping (V) throws -> CodableValue,
        decode: @escaping (CodableValue) throws -> V
    ) -> UserDefaultsKey
    where
        CodableValue: Codable,
        Value == V?
    {
        UserDefaultsKey(
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
    // swiftlint:enable opening_brace
}

struct UnexpectedType: Error {
    let value: Any?
}

extension CoreStorage.UserDefaultsKey where Stored == Data {

    // swiftlint:disable opening_brace
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
    ) -> Self
    where
        Value == V?,
        RootObject: UserDefaultsStorable
    {
        Self(
            name: name,
            encode: { value in
                let root = try encode(value)
                return try NSKeyedArchiver.archivedData(withRootObject: root, requiringSecureCoding: false)
            },
            decode: { data in
                let unarchived = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
                guard let root = unarchived as? RootObject else { throw UnexpectedType(value: unarchived) }
                return try decode(root)
            })
    }

    public static func keyedArchiver<RootObject>(
        name: String,
        default: Value,
        encode: @escaping (Value) throws -> RootObject,
        decode: @escaping (RootObject) throws -> Value
    ) -> Self
    where
        RootObject: UserDefaultsStorable
    {
        Self(
            name: name,
            default: `default`,
            encode: { value in
                let root = try encode(value)
                return try NSKeyedArchiver.archivedData(withRootObject: root, requiringSecureCoding: false)
            },
            decode: { data in
                let unarchived = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
                guard let root = unarchived as? RootObject else { throw UnexpectedType(value: unarchived) }
                return try decode(root)
            })
    }
    // swiftlint:enable opening_brace
}

// MARK: - UserDefaults Access

extension UserDefaults {

    /// Returns the value associated with the specified key.
    ///
    /// - Parameter key: A key in the current user‘s defaults database.
    /// - Returns: The value associated with the specified key, or the key's
    ///            default if the value was not found.
    public func value<Value, Stored>(for key: UserDefaultsKey<Value, Stored>) -> Value {
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
    public func value<Value>(for key: UserDefaultsKey<Value, URL>) -> Value {
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
    public func set<Value, Stored>(_ value: Value, for key: UserDefaultsKey<Value, Stored>) {
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
    public func set<Value, Stored>(_ value: Value?, for key: UserDefaultsKey<Value?, Stored>) {

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
    public func removeValue<Value, Stored>(for key: UserDefaultsKey<Value, Stored>) {
        removeObject(forKey: key.name)
    }
}

// MARK: - UserDefaults Conveniences

extension UserDefaults {

    public func increment<Value, Stored>(
        _ key: UserDefaultsKey<Value, Stored>
    ) where Value: Numeric {
        let current = value(for: key)
        set(current + 1, for: key)
    }
}

// MARK: - UserDefaults Legacy

/// Represents a key used for `UserDefaults` where the stored data is no longer needed.
///
/// It is intended to be used solely for the purpose of removing legacy data from `UserDefaults`.
public struct UserDefaultsLegacyKey {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

extension UserDefaults {

    /// Removes the values of the specified legacy keys.
    ///
    /// - Parameter key: The keys whose values you want to remove.
    public func removeValues(for keys: [UserDefaultsLegacyKey]) {
        keys.forEach { removeObject(forKey: $0.name) }
    }
}
