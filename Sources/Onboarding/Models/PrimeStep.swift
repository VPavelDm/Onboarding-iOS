//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 28.09.24.
//

import Foundation

struct PrimeStep: Sendable, Equatable, Hashable {
    var title: String
    var description: String
    var answer: StepAnswer
}

// MARK: - Convert

extension PrimeStep {

    init(response: OnboardingStepResponse.PrimeStep) {
        self.init(
            title: response.title,
            description: response.description,
            answer: StepAnswer(response: response.answer)
        )
    }
}
