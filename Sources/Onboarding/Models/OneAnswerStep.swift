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

    init(response: OnboardingStepResponse.OneAnswerStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            description: response.description?.localized(using: localizer),
            buttonTitle: response.buttonTitle.localized(using: localizer),
            skip: response.skip.map { StepAnswer(response: $0, localizer: localizer) },
            answers: response.answers.map { StepAnswer(response: $0, localizer: localizer) }
        )
    }
}
