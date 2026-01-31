//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 08.09.24.
//

import Foundation

struct WelcomeStep: Sendable, Equatable, Hashable {
    let title: String
    let description: String
    let emojis: [String]
    let firstAnswer: StepAnswer
    let secondAnswer: StepAnswer?
}

// MARK: - Convert

extension WelcomeStep {

    init(response: OnboardingStepResponse.WelcomeStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            description: response.description.localized(using: localizer),
            emojis: response.emojis,
            firstAnswer: StepAnswer(response: response.firstAnswer, localizer: localizer),
            secondAnswer: response.secondAnswer.map { StepAnswer(response: $0, localizer: localizer) }
        )
    }
}
