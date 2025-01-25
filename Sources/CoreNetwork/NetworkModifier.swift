//
//  NetworkModifier.swift
//  VirtualChampionsLeague
//
//  Created by Pavel Vaitsikhouski on 17.10.22.
//

import Foundation

/// Encapsulate a modification to network request and responses.
public struct NetworkModifier: Sendable {
    public let modifyRequest: @Sendable (inout URLRequest) throws -> Void
    public let modifyResponse: @Sendable (inout (Data, URLResponse)) throws -> Void

    public init(
        modifyRequest: @Sendable @escaping (inout URLRequest) throws -> Void = { _ in },
        modifyResponse: @Sendable @escaping (inout (Data, URLResponse)) throws -> Void = { _ in }
    ) {
        self.modifyRequest = modifyRequest
        self.modifyResponse = modifyResponse
    }
}
