//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 30.03.25.
//

import Foundation

struct WelcomeFadeStep: Sendable, Equatable, Hashable {
    let messages: [String]
    let answer: StepAnswer
}

// MARK: - Convert

extension WelcomeFadeStep {

    init(response: OnboardingStepResponse.WelcomeFadeStep) {
        self.init(
            messages: response.messages,
            answer: StepAnswer(response: response.answer)
        )
    }
}
