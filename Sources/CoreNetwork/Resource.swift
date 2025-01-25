//
//  Resource.swift
//  VirtualChampionsLeague
//
//  Created by Pavel Vaitsikhouski on 17.10.22.
//

import Foundation

/// Encapsulates the creation of a network request and the transformation of the
/// data into a usable type.
public struct Resource<Value>: Sendable {
    public let makeRequest: @Sendable () throws -> URLRequest
    public let transform: @Sendable ((Data, URLResponse)) throws -> Value

    /// Create a resource.
    ///
    /// - Parameters:
    ///   - makeRequest: Used to create the URL request.
    ///   - transform: Used to transform the response of the network call.
    public init(
        makeRequest: @Sendable @escaping () throws -> URLRequest,
        transform: @Sendable @escaping ((Data, URLResponse)) throws -> Value
    ) {
        self.makeRequest = makeRequest
        self.transform = transform
    }
}

// MARK: - Initializers

extension Resource {

    /// Create a resource.
    ///
    /// - Parameters:
    ///   - request: The request to perform.
    ///   - transform: Used to transform the response of the network call.
    public init(request: URLRequest, transform: @Sendable @escaping (Data, URLResponse) throws -> Value) {
        self.init(makeRequest: { request }, transform: transform)
    }
}

extension Resource where Value: Decodable {

    /// Creates a Resource when the Value is Decodable.
    ///
    /// - Parameters:
    ///   - makeRequest: Used to create the URL request.
    ///   - decoder: The JSON decoder to use. `JSONDecoder()` is default.
    public init(makeRequest: @Sendable @escaping () throws -> URLRequest, decoder: JSONDecoder = JSONDecoder()) {
        self.init(makeRequest: makeRequest) { data, _ in
            try decoder.decode(Value.self, from: data)
        }
    }

    /// Creates a Resource when the Value is Decodable.
    ///
    /// - Parameters:
    ///   - request: The request to perform.
    ///   - decoder: The JSON decoder to use. `JSONDecoder()` is default.
    public init(request: URLRequest, decoder: JSONDecoder = JSONDecoder()) {
        self.init(makeRequest: { request }, decoder: decoder)
    }
}

// MARK: - Transforming

extension Resource {

    public func tryMap<NewValue>(
        _ transform: @Sendable @escaping (Value) throws -> NewValue
    ) -> Resource<NewValue> where Value: Sendable, NewValue: Sendable {

        Resource<NewValue>(makeRequest: makeRequest) { response in
            try transform(self.transform(response))
        }
    }
    
    public func tryMap<NewValue, ErrorType: Decodable & Error>(
        _ transform: @Sendable @escaping (Value) throws -> NewValue,
        errorType: ErrorType.Type
    ) -> Resource<NewValue> {
        
        Resource<NewValue>(makeRequest: makeRequest) { data, response in
            do {
                return try transform(self.transform((data, response)))
            } catch {
                throw try JSONDecoder().decode(ErrorType.self, from: data)
            }
        }
    }

    /// Replaces all errors that occur during `transform` with the given value.
    ///
    /// - Parameter value: The value to use when the `transform` fails.
    /// - Returns: A new resource with new error handling.
    public func replaceError(with value: Value) -> Self where Value: Sendable {
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
        Resource(makeRequest: {
            var request = try makeRequest()
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
