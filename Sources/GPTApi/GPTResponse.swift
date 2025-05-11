//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 11.05.25.
//

import Foundation

public struct GPTResponse: Codable {
    let choices: [Choice]
    let model: String

    struct Choice: Codable {
        let message: GPTMessage
    }
}
