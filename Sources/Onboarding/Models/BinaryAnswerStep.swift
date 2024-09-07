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
    let firstAnswer: Answer
    let secondAnswer: Answer

    struct Answer: Sendable, Equatable, Hashable {
        let text: String
        let icon: String?
    }
}

// MARK: - Convert

extension BinaryAnswerStep {

    init(response: OnboardingStepResponse.BinaryAnswer) {
        self.init(
            title: response.title,
            description: response.description,
            firstAnswer: Answer(
                text: response.firstAnswer.text,
                icon: response.firstAnswer.icon
            ),
            secondAnswer: Answer(
                text: response.secondAnswer.text,
                icon: response.secondAnswer.icon
            )
        )
    }
}
