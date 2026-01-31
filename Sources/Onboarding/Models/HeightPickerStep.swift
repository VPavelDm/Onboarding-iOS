//
//  HeightPickerStep.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.01.26.
//

import Foundation

struct HeightPickerStep: Sendable, Equatable, Hashable {
    var title: String
    var description: String?
    var answer: StepAnswer
}

// MARK: - Convert

extension HeightPickerStep {

    init(response: OnboardingStepResponse.HeightPickerStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            description: response.description?.localized(using: localizer),
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
