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

    init(response: OnboardingStepResponse.EnterValueStep, bundle: Bundle) {
        self.init(
            title: response.title.localized(bundle: bundle),
            description: response.description?.localized(bundle: bundle),
            placeholder: response.placeholder.localized(bundle: bundle),
            valueType: response.valueType,
            primaryAnswer: StepAnswer(response: response.primaryAnswer, bundle: bundle),
            skipAnswer: response.skipAnswer.map { StepAnswer(response: $0, bundle: bundle) }
        )
    }
}
