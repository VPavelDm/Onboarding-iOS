#if canImport(Combine) && canImport(SwiftUI)

import Combine
import SwiftUI

/// A property wrapper for a value in user defaults.
@propertyWrapper
public struct UserDefault<Value, Stored: UserDefaultsStorable>: DynamicProperty {

    private let defaults: UserDefaults
    private let key: UserDefaultsKey<Value, Stored>
    @ObservedObject private var observable: Observable<Value, Stored>

    /// Creates a dynamic UserDefault property wrapper to access the value for
    /// the given key.
    ///
    /// - Parameters:
    ///   - key: The key for the desired value
    ///   - defaults: The user defaults storage to access.
    public init(_ key: UserDefaultsKey<Value, Stored>, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
        observable = Observable(defaults: defaults, key: key)
    }

    /// The value stored in user defaults for the given key.
    public var wrappedValue: Value {
        get { observable.value }
        nonmutating set { observable.value = newValue }
    }

    /// A binding to the value in stored in user defaults.
    public var projectedValue: Binding<Value> { $observable.value }

    public mutating func update() { _observable.update() }
}

private final class Observable<Value, Stored: UserDefaultsStorable>: ObservableObject {

    let objectWillChange: ObservableObjectPublisher
    let defaults: UserDefaults
    let key: UserDefaultsKey<Value, Stored>
    var observation: KeyValueObservation<Value>

    var value: Value {
        get { defaults.value(for: key) }
        set { defaults.set(newValue, for: key) }
    }

    init(defaults: UserDefaults, key: UserDefaultsKey<Value, Stored>) {
        let objectWillChange = ObservableObjectPublisher()
        self.defaults = defaults
        self.key = key
        self.objectWillChange = objectWillChange
        self.observation = KeyValueObservation(
            object: defaults,
            keyPath: key.name,
            default: key.default
        ) { change in
            guard case .willSet = change else { return }
            objectWillChange.send()
        }
    }
}

/// A class to observe values using a string-based keypath.
private final class KeyValueObservation<Value>: NSObject {

    enum Change {
        case willSet(oldValue: Value, newValue: Value)
        case didSet(oldValue: Value, newValue: Value)
    }

    private weak var object: NSObject? {
        willSet {
            guard newValue == nil else { return }
            removeObserver()
        }
    }

    private let keyPath: String
    private let `default`: Value
    private let handler: (Change) -> Void

    init(object: NSObject,
         keyPath: String,
         default: Value,
         handler: @escaping (Change) -> Void) {

        self.object = object
        self.keyPath = keyPath
        self.default = `default`
        self.handler = handler
        super.init()
        addObserver()
    }

    deinit {
        removeObserver()
    }

    private func addObserver() {
        object?.addObserver(self, forKeyPath: keyPath, options: [.old, .new, .prior], context: nil)
    }

    private func removeObserver() {
        object?.removeObserver(self, forKeyPath: keyPath, context: nil)
    }

    // swiftlint:disable block_based_kvo
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change dictionary: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard self.object == object as? NSObject else { return }
        guard let dictionary = dictionary else { return }
        handler(change(for: dictionary))
    }
    // swiftlint:enable block_based_kvo

    private func change(for values: [NSKeyValueChangeKey: Any]) -> Change {
        let old = values[.oldKey] as? Value ?? `default`
        let new = values[.newKey] as? Value ?? `default`
        let isPrior = values[.notificationIsPriorKey] as? Bool ?? false

        if isPrior {
            return .willSet(oldValue: old, newValue: new)
        } else {
            return .didSet(oldValue: old, newValue: new)
        }
    }
}

#endif
