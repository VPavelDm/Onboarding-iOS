//
//  Resource.swift
//  CoreNetwork
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

/// Encapsulates the creation of a network request and the transformation of the
/// data into a usable type.
public struct Resource<Value> {
    public let makeRequest: (NetworkEnvironment) throws -> URLRequest
    public let transform: ((Data, URLResponse)) throws -> Value

    /// Create a resource.
    ///
    /// - Parameters:
    ///   - makeRequest: Used to create the URL request.
    ///   - transform: Used to transform the response of the network call.
    public init(
        makeRequest: @escaping (NetworkEnvironment) throws -> URLRequest,
        transform: @escaping ((Data, URLResponse)) throws -> Value
    ) {
        self.makeRequest = makeRequest
        self.transform = transform
    }
}

// MARK: - Transforming

extension Resource {

    public func tryMap<NewValue>(
        _ transform: @escaping (Value) throws -> NewValue
    ) -> Resource<NewValue> {

        Resource<NewValue>(makeRequest: makeRequest) { response in
            try transform(self.transform(response))
        }
    }

    /// Replaces all errors that occur during `transform` with the given value.
    ///
    /// - Parameter value: The value to use when the `transform` fails.
    /// - Returns: A new resource with new error handling.
    public func replaceError(with value: Value) -> Self {
        Resource(makeRequest: makeRequest) { response in
            do {
                return try transform(response)
            } catch {
                return value
            }
        }
    }

    /// Modifies the resource using a network modifier.
    ///
    /// - Parameter modifier:
    /// - Returns: The modified resource.
    public func modify(_ modifier: NetworkModifier) -> Resource {
        Resource(makeRequest: { networkEnvironment in
            var request = try makeRequest(networkEnvironment)
            try modifier.modifyRequest(&request)
            return request
        }, transform: { response in
            var response = response
            try modifier.modifyResponse(&response)
            return try transform(response)
        })
    }

    /// Modifies the resource using an array of network modifiers.
    ///
    /// These are applied one after the other.
    ///
    /// - Parameter modifiers: The network modifiers to use.
    /// - Returns: The modified resource.
    public func modify(_ modifiers: [NetworkModifier]) -> Resource {
        modifiers.reduce(self) { resource, modifier in
            resource.modify(modifier)
        }
    }
}
