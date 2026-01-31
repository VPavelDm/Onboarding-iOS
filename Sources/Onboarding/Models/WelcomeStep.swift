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

    init(response: OnboardingStepResponse.WelcomeStep, bundle: Bundle) {
        self.init(
            title: response.title.localized(bundle: bundle),
            description: response.description.localized(bundle: bundle),
            emojis: response.emojis,
            firstAnswer: StepAnswer(response: response.firstAnswer, bundle: bundle),
            secondAnswer: response.secondAnswer.map { StepAnswer(response: $0, bundle: bundle) }
        )
    }
}
