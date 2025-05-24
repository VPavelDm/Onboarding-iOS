//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 11.05.25.
//

import Foundation

public struct GPTResponse: Codable {
    public let choices: [Choice]
    public let model: String

    public struct Choice: Codable {
        public let message: GPTMessage
    }
}
