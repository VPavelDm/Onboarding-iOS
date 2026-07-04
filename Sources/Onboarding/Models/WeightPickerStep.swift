//
//  WeightPickerStep.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.01.26.
//

import Foundation

struct WeightPickerStep: Sendable, Equatable, Hashable {
    var title: String
    var description: String?
    var metricUnit: String
    var imperialUnit: String
    var answer: StepAnswer
}

// MARK: - Convert

extension WeightPickerStep {

    init(response: OnboardingStepResponse.WeightPickerStep) {
        self.init(
            title: response.title,
            description: response.description,
            metricUnit: response.metricUnit,
            imperialUnit: response.imperialUnit,
            answer: StepAnswer(response: response.answer)
        )
    }
}
