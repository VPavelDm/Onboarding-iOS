//
//  URLRequest+HTTPHeaderField.swift
//  CoreNetwork
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

extension URLRequest {

    /// Represents a header field key-value pair.
    public struct HTTPHeaderField {
        public let key: String
        public let value: String

        public init(key: String, value: String) {
            self.key = key
            self.value = value
        }
    }

    /// Adds a header field.
    ///
    /// - Parameter header: The header to add.
    public mutating func addHTTPHeaderField(_ header: HTTPHeaderField) {
        addValue(header.value, forHTTPHeaderField: header.key)
    }

}
