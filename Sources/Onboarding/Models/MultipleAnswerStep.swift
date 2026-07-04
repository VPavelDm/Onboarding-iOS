//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

struct MultipleAnswerStep: Sendable, Equatable, Hashable {
    let title: String
    let description: String?
    let image: ImageMeta?
    let buttonTitle: String
    let minAnswersAmount: Int
    let answers: [StepAnswer]
}

// MARK: - Convert

extension MultipleAnswerStep {

    init(response: OnboardingStepResponse.MultipleAnswerStep) {
        self.init(
            title: response.title,
            description: response.description,
            image: response.image.flatMap(ImageMeta.init),
            buttonTitle: response.buttonTitle,
            minAnswersAmount: response.minAnswersAmount,
            answers: response.answers.map { StepAnswer(response: $0) }
        )
    }
}
