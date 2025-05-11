//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 11.05.25.
//

import Foundation

public struct GPTRequestBody: Encodable {
    var model: String = "gpt-4o-mini"
    var messages: [GPTMessage]
    var responseFormat: AnyEncodable?

    public init(messages: [GPTMessage], responseFormat: AnyEncodable?) throws {
        self.messages = messages
        self.responseFormat = responseFormat
    }

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case responseFormat = "response_format"
    }
}

private extension GPTRequestBody {

    var json: String {
        get throws {
            let data = try JSONEncoder().encode(self)
            return String(data: data, encoding: .utf8)!
        }
    }
}
