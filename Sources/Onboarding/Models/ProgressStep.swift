//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 18.09.24.
//

import Foundation

struct ProgressStep: Sendable, Equatable, Hashable {
    var title: String
    var description: String?
    var steps: [String]
    var answer: StepAnswer
}

// MARK: - Convert

extension ProgressStep {

    init(response: OnboardingStepResponse.ProgressStep) {
        self.init(
            title: response.title,
            description: response.description,
            steps: response.steps,
            answer: StepAnswer(response: response.answer)
        )
    }
}
