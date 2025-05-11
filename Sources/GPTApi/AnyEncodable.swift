//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 11.05.25.
//

import Foundation

public struct AnyEncodable: Encodable {
    let value: Any

    public init(value: Any) {
        self.value = value
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if let value = value as? [Any] {
            let nestedValues = value.map { AnyEncodable(value: $0) }
            try container.encode(nestedValues)
        } else if let value = value as? [String: Any] {
            let nestedValues = value.mapValues { AnyEncodable(value: ($0)) }
            try container.encode(nestedValues)
        }
    }
}
