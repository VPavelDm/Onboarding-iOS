//
//  URLSession+SwiftConcurrency.swift
//  CoreNetwork
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
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
    public func value<Value>(for resource: Resource<Value>) async throws -> Value {
        try await withCheckedThrowingContinuation { continuation in
            fetch(resource, completion: continuation.resume)
        }
    }
}
