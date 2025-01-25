//
//  URLSession+SwiftConcurrency.swift
//  VirtualChampionsLeague
//
//  Created by Pavel Vaitsikhouski on 17.10.22.
//

import Foundation

extension URLSession {

    /// Retrieves the given resource and delivers the result asynchronously.
    ///
    /// This uses the resource's `makeRequest` function to create the URL
    /// request and its `transform` function to create the value to return.
    ///
    /// - Parameters:
    ///   - resource: The resource to fetch.
    /// - Returns: The value transformed from the network data by the resource.
    public func value<Value: Sendable>(for resource: Resource<Value>) async throws -> Value {
        try await withCheckedThrowingContinuation { continuation in
            fetch(resource) { result in
                continuation.resume(with: result)
            }
        }
    }
}
