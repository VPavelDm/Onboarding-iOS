//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 27.09.24.
//

import Foundation

struct DiscountWheelStep: Sendable, Equatable, Hashable {
    var title: String
    var spinButtonTitle: String
    var spinFootnote: String
    var successTitle: String
    var successDescription: String
    var answer: StepAnswer
}

// MARK: - Convert

extension DiscountWheelStep {

    init(response: OnboardingStepResponse.DiscountWheelStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            spinButtonTitle: response.spinButtonTitle.localized(using: localizer),
            spinFootnote: response.spinFootnote.localized(using: localizer),
            successTitle: response.successTitle.localized(using: localizer),
            successDescription: response.successDescription.localized(using: localizer),
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
