//
//  URLRequest+Body.swift
//  CoreNetwork
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

extension URLRequest {

    /// A request that POSTs an `HTTPBody`.
    public init(posting body: HTTPBody, to url: URL) {
        self.init(url: url)
        setHTTPBody(body)
        httpMethod = "POST"
    }
    
    /// A struct to describe the body data of a request.
    public struct HTTPBody {
        fileprivate let data: Data
        fileprivate let contentType: ContentType
    }

    /// Set the data sent as the message body of a request, such as for an HTTP
    /// POST request.
    ///
    /// This also sets the content type of the data.
    /// - Parameter body: The body to set.
    public mutating func setHTTPBody(_ body: HTTPBody) {
        httpBody = body.data
        addHTTPHeaderField(.contentType(body.contentType))
    }
}

private struct ContentType {
    let name: String
}

extension ContentType {
    static let json = Self(name: "application/json")
    static func multipart(boundary: String) -> Self {
        Self(name: "multipart/form-data; boundary=\(boundary)")
    }
}

extension URLRequest.HTTPHeaderField {

    fileprivate static func contentType(_ type: ContentType) -> Self {
        Self(key: "Content-Type", value: type.name)
    }
}

extension URLRequest.HTTPBody {

    /// Returns a json body value which can be used to set the httpBody and
    /// Content-Type header of a URLRequest using ``URLRequest.setBody(_:)``.
    ///
    /// - Parameter data: The json body data.
    /// - Returns: The body value.
    public static func json<Value: Encodable>(
        _ value: Value,
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> Self {
        let data = try encoder.encode(value)
        return Self(data: data, contentType: .json)
    }
}
