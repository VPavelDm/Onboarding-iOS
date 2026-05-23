//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 27.09.24.
//

import Foundation

struct DiscountWheelStep: Sendable, Equatable, Hashable {
    var nextStepID: StepID?
}

// MARK: - Convert

extension DiscountWheelStep {

    init(response: OnboardingStepResponse.DiscountWheelStep, localizer: Localizer) {
        self.init(nextStepID: response.nextStepID)
    }
}
