//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 29.03.25.
//

import Foundation

struct EnterValueStep: Sendable, Hashable {
    var title: String
    var description: String?
    var valueType: String
    var answer: StepAnswer
}

// MARK: - Convert

extension EnterValueStep {

    init(response: OnboardingStepResponse.EnterValueStep) {
        self.title = response.title
        self.description = response.description
        self.valueType = response.valueType
        self.answer = StepAnswer(response: response.answer)
    }
}
