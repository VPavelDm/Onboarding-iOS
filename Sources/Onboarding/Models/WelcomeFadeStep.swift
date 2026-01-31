//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 30.03.25.
//

import Foundation

struct WelcomeFadeStep: Sendable, Equatable, Hashable {
    let messages: [String]
    let delay: TimeInterval
}

// MARK: - Convert

extension WelcomeFadeStep {

    init(response: OnboardingStepResponse.WelcomeFadeStep, localizer: Localizer) {
        self.init(
            messages: response.messages.map { $0.localized(using: localizer) },
            delay: response.delay
        )
    }
}
