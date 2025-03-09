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
    let answers: [StepAnswer]
}

// MARK: - Convert

extension OneAnswerStep {

    init(response: OnboardingStepResponse.OneAnswerStep) {
        self.init(
            title: response.title,
            description: response.description,
            buttonTitle: response.buttonTitle,
            answers: response.answers.map(StepAnswer.init(response:))
        )
    }
}
