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
    var unit: String
    var answer: StepAnswer
}

// MARK: - Convert

extension AgePickerStep {

    init(response: OnboardingStepResponse.AgePickerStep) {
        self.init(
            title: response.title,
            description: response.description,
            unit: response.unit,
            answer: StepAnswer(response: response.answer)
        )
    }
}
