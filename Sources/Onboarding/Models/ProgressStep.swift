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

    init(response: OnboardingStepResponse.ProgressStep, bundle: Bundle) {
        self.init(
            title: response.title.localized(bundle: bundle),
            description: response.description?.localized(bundle: bundle),
            duration: response.duration,
            steps: response.steps.map { $0.localized(bundle: bundle) },
            answer: StepAnswer(response: response.answer, bundle: bundle)
        )
    }
}
