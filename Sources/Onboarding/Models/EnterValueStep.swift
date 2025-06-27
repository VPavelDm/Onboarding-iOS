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
    var placeholder: String
    var valueType: String
    var primaryAnswer: StepAnswer
    var skipAnswer: StepAnswer?
}

// MARK: - Convert

extension EnterValueStep {

    init(response: OnboardingStepResponse.EnterValueStep) {
        self.init(
            title: response.title,
            description: response.description,
            placeholder: response.placeholder,
            valueType: response.valueType,
            primaryAnswer: StepAnswer(response: response.primaryAnswer),
            skipAnswer: response.skipAnswer.map(StepAnswer.init(response:))
        )
    }
}
