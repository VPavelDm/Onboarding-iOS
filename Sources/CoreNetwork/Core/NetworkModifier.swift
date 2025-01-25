//
//  NetworkModifier.swift
//  CoreNetwork
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

/// Encapsulate a modification to network request and responses.
public struct NetworkModifier {
    public let modifyRequest: (inout URLRequest) throws -> Void
    public let modifyResponse: (inout (Data, URLResponse)) throws -> Void

    public init(
        modifyRequest: @escaping (inout URLRequest) throws -> Void = { _ in },
        modifyResponse: @escaping (inout (Data, URLResponse)) throws -> Void = { _ in }
    ) {
        self.modifyRequest = modifyRequest
        self.modifyResponse = modifyResponse
    }
}
