//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

struct OneAnswerStep: Sendable, Equatable, Hashable {
    let title: String
    let description: String?
    let buttonTitle: String
    let skip: StepAnswer?
    let answers: [StepAnswer]
}

// MARK: - Convert

extension OneAnswerStep {

    init(response: OnboardingStepResponse.OneAnswerStep, bundle: Bundle) {
        self.init(
            title: response.title.localized(bundle: bundle),
            description: response.description?.localized(bundle: bundle),
            buttonTitle: response.buttonTitle.localized(bundle: bundle),
            skip: response.skip.map { StepAnswer(response: $0, bundle: bundle) },
            answers: response.answers.map { StepAnswer(response: $0, bundle: bundle) }
        )
    }
}
