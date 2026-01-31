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

    init(response: OnboardingStepResponse.MultipleAnswerStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            description: response.description?.localized(using: localizer),
            buttonTitle: response.buttonTitle.localized(using: localizer),
            minAnswersAmount: response.minAnswersAmount,
            answers: response.answers.map { StepAnswer(response: $0, localizer: localizer) }
        )
    }
}
