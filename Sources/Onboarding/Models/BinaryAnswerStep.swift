//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

struct BinaryAnswerStep: Sendable, Equatable, Hashable {
    let title: String
    let description: String?
    let firstAnswer: StepAnswer
    let secondAnswer: StepAnswer
}

// MARK: - Convert

extension BinaryAnswerStep {

    init(response: OnboardingStepResponse.BinaryAnswer, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            description: response.description?.localized(using: localizer),
            firstAnswer: StepAnswer(response: response.firstAnswer, localizer: localizer),
            secondAnswer: StepAnswer(response: response.secondAnswer, localizer: localizer)
        )
    }
}
