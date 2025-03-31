//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 30.03.25.
//

import Foundation

struct WelcomeFadeStep: Sendable, Equatable, Hashable {
    let messages: [String]
}

// MARK: - Convert

extension WelcomeFadeStep {

    init(response: OnboardingStepResponse.WelcomeFadeStep) {
        self.init(messages: response.messages)
    }
}
