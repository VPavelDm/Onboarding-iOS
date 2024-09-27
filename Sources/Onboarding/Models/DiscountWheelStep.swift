//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 27.09.24.
//

import Foundation

struct DiscountWheelStep: Sendable, Equatable, Hashable {
    var title: String
}

// MARK: - Convert

extension DiscountWheelStep {

    init(response: OnboardingStepResponse.DiscountWheelStep) {
        self.init(
            title: response.title
        )
    }
}
