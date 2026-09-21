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
    /// Where the flow goes once the last message has shown. Absent means the step that follows this
    /// one in the steps file.
    let nextStepID: StepID?
}

// MARK: - Convert

extension WelcomeFadeStep {

    init(response: OnboardingStepResponse.WelcomeFadeStep) {
        self.init(
            messages: response.messages.map { $0 },
            delay: response.delay,
            nextStepID: response.nextStepID
        )
    }
}
