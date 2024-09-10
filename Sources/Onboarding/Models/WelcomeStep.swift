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
    let secondAnswer: StepAnswer
}

// MARK: - Convert

extension WelcomeStep {

    init(response: OnboardingStepResponse.WelcomeStep) {
        self.init(
            title: response.title,
            description: response.description,
            emojis: response.emojis,
            firstAnswer: StepAnswer(response: response.firstAnswer),
            secondAnswer: StepAnswer(response: response.secondAnswer)
        )
    }
}
