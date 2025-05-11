//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 11.05.25.
//

import Foundation

public struct GPTRequestBody: Codable {
    let model: String
    let responseFormat: String
    let messages: [GPTMessage]

    public init(model: String, responseFormat: String, messages: [GPTMessage]) {
        self.model = model
        self.responseFormat = responseFormat
        self.messages = messages
    }
}
