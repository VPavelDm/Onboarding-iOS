//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 08.05.25.
//

import Foundation

public final class DependencyContainer {

    private static let shared = DependencyContainer()

    private init() {}

    private var singletons: [ObjectIdentifier: Any] = [:]
    private var lazySingletons: [ObjectIdentifier: () -> Any] = [:]
    private var typeConstructs: [ObjectIdentifier: () -> Any] = [:]

    /// Registers the provided instance as a singleton for the provided type.
    @MainActor
    public class func registerSingleton<T>(_ instance: T, for interface: T.Type) {
        Self.shared.singletons[ObjectIdentifier(interface)] = instance
        Self.shared.lazySingletons.removeValue(forKey: ObjectIdentifier(interface))
    }

    /// Registers a singleton constructor for the provided type. Resolving for this type for the first time will call the constructor and register the resulting instance as a singleton for the provided type.
    @MainActor
    public class func registerLazySingleton<T>(_ construct: @escaping () -> T, for interface: T.Type) {
        Self.shared.lazySingletons[ObjectIdentifier(interface)] = construct
    }

    /// Registers a constructor for the provided type. Each resolve call for this type will call the constructor and return the created instance. So, resolving for this type will create a new instance every time (not a singleton).
    @MainActor
    public class func registerConstructor<T>(_ construct: @escaping () -> T, for interface: T.Type) {
        Self.shared.typeConstructs[ObjectIdentifier(interface)] = construct
    }

    /// Tries to resolve an instance for the inferred type. Will crash the app if nothing is registered for the inferred type.
    public class func resolve<T>() -> T {
        do {
            return try resolve(T.self)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /// Tries to resolve an instance for the provided type. Will throw an error if nothing is registered for the provided type.
    public class func resolve<T>(_ interface: T.Type) throws -> T {
        let id = ObjectIdentifier(interface)

        if let typeConstruct = Self.shared.typeConstructs[id] {
            let instance = typeConstruct()
            guard let typedInstance = instance as? T else {
                throw DependencyContainerError.incompatibleTypes(interfaceType: interface, implementationType: type(of: instance))
            }

            return typedInstance
        }

        if let lazyValue = Self.shared.lazySingletons.removeValue(forKey: id) {
            Self.shared.singletons[id] = lazyValue()
        }

        if let singleton = Self.shared.singletons[id] {
            guard let typedSingleton = singleton as? T else {
                throw DependencyContainerError.incompatibleTypes(interfaceType: interface, implementationType: type(of: singleton))
            }

            return typedSingleton
        }

        throw DependencyContainerError.nothingRegisteredForType(typeIdentifier: interface)
    }

    /// Used in DependencyContainerTests Tests
    @MainActor
    class func unregisterAll() {
        Self.shared.singletons.removeAll()
        Self.shared.lazySingletons.removeAll()
        Self.shared.typeConstructs.removeAll()
    }
}

public enum DependencyContainerError: Error {
    case nothingRegisteredForType(typeIdentifier: Any.Type)
    case incompatibleTypes(interfaceType: Any.Type, implementationType: Any.Type)
}
