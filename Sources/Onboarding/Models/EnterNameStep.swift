//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 29.03.25.
//

import Foundation

struct EnterNameStep: Sendable, Hashable {
    let title: String
    let description: String
    let answer: StepAnswer
}

// MARK: - Convert

extension EnterNameStep {

    init(response: OnboardingStepResponse.EnterNameStep) {
        self.title = response.title
        self.description = response.description
        self.answer = StepAnswer(response: response.answer)
    }
}
