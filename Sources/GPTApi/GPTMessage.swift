//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 11.05.25.
//

import Foundation

public struct GPTMessage: Codable {
    public let role: String
    public let content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}
