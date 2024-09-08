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
    let image: ImageType?
    let firstAnswer: StepAnswer
    let secondAnswer: StepAnswer
}

// MARK: - Convert

extension WelcomeStep {

    init(response: OnboardingStepResponse.WelcomeStep) {
        self.init(
            title: response.title,
            description: response.description,
            image: ImageType(response: response.image),
            firstAnswer: StepAnswer(response: response.firstAnswer),
            secondAnswer: StepAnswer(response: response.secondAnswer)
        )
    }
}
