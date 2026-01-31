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

    init(response: OnboardingStepResponse.DiscountWheelStep, bundle: Bundle) {
        self.init(
            title: response.title.localized(bundle: bundle),
            spinButtonTitle: response.spinButtonTitle.localized(bundle: bundle),
            spinFootnote: response.spinFootnote.localized(bundle: bundle),
            successTitle: response.successTitle.localized(bundle: bundle),
            successDescription: response.successDescription.localized(bundle: bundle),
            answer: StepAnswer(response: response.answer, bundle: bundle)
        )
    }
}
