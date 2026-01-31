//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

struct MultipleAnswerStep: Sendable, Equatable, Hashable {
    let title: String
    let description: String?
    let buttonTitle: String
    let minAnswersAmount: Int
    let answers: [StepAnswer]
}

// MARK: - Convert

extension MultipleAnswerStep {

    init(response: OnboardingStepResponse.MultipleAnswerStep, bundle: Bundle) {
        self.init(
            title: response.title.localized(bundle: bundle),
            description: response.description?.localized(bundle: bundle),
            buttonTitle: response.buttonTitle.localized(bundle: bundle),
            minAnswersAmount: response.minAnswersAmount,
            answers: response.answers.map { StepAnswer(response: $0, bundle: bundle) }
        )
    }
}
