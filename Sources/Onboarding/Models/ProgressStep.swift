//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 18.09.24.
//

import Foundation

struct ProgressStep: Sendable, Equatable, Hashable {
    var title: String
    var description: String?
    var duration: Double
    var steps: [String]
    var answer: StepAnswer
}

// MARK: - Convert

extension ProgressStep {

    init(response: OnboardingStepResponse.ProgressStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            description: response.description?.localized(using: localizer),
            duration: response.duration,
            steps: response.steps.map { $0.localized(using: localizer) },
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
