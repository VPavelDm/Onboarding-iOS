//
//  AgePickerStep.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.01.26.
//

import Foundation

struct AgePickerStep: Sendable, Equatable, Hashable {
    var title: String
    var description: String?
    var answer: StepAnswer
}

// MARK: - Convert

extension AgePickerStep {

    init(response: OnboardingStepResponse.AgePickerStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            description: response.description?.localized(using: localizer),
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
