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

    init(response: OnboardingStepResponse.BinaryAnswer) {
        self.init(
            title: response.title,
            description: response.description,
            firstAnswer: StepAnswer(response: response.firstAnswer),
            secondAnswer: StepAnswer(response: response.secondAnswer)
        )
    }
}
