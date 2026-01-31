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

    init(response: OnboardingStepResponse.EnterValueStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            description: response.description?.localized(using: localizer),
            placeholder: response.placeholder.localized(using: localizer),
            valueType: response.valueType,
            primaryAnswer: StepAnswer(response: response.primaryAnswer, localizer: localizer),
            skipAnswer: response.skipAnswer.map { StepAnswer(response: $0, localizer: localizer) }
        )
    }
}
