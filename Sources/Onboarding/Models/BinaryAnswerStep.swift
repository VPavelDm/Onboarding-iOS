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

    init(response: OnboardingStepResponse.BinaryAnswer, bundle: Bundle) {
        self.init(
            title: response.title.localized(bundle: bundle),
            description: response.description?.localized(bundle: bundle),
            firstAnswer: StepAnswer(response: response.firstAnswer, bundle: bundle),
            secondAnswer: StepAnswer(response: response.secondAnswer, bundle: bundle)
        )
    }
}
