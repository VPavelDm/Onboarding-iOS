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
    let image: ImageMeta?
    let buttonTitle: String
    let skip: StepAnswer?
    let answers: [StepAnswer]
    let autoNavigateOnSingleAnswer: Bool
}

// MARK: - Convert

extension OneAnswerStep {

    init(response: OnboardingStepResponse.OneAnswerStep) {
        self.init(
            title: response.title,
            description: response.description,
            image: response.image.flatMap(ImageMeta.init),
            buttonTitle: response.buttonTitle,
            skip: response.skip.map { StepAnswer(response: $0) },
            answers: response.answers.map { StepAnswer(response: $0) },
            autoNavigateOnSingleAnswer: response.autoNavigateOnSingleAnswer ?? false
        )
    }
}
