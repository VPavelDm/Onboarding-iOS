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

public extension GPTRequestBody {

    init(fileName: String, systemMessage: String, userMessage: String) throws {
        guard let responseFormat = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw FillError.responseFormatFileNotExists
        }
        let data = try Data(contentsOf: responseFormat)
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
            throw FillError.stringFormatError
        }

        let messages: [GPTMessage] = [
            GPTMessage(role: "system", content: systemMessage),
            GPTMessage(role: "user", content: userMessage)
        ]

        self = try .init(
            messages: messages,
            responseFormat: AnyEncodable(value: jsonObject)
        )
    }

    private enum FillError: Error {
        case responseFormatFileNotExists
        case dataFormatError
        case stringFormatError
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
