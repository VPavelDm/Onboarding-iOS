//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

extension OneAnswerStep {

    static func testData() -> Self {
        Self(
            title: "What's your main goal?",
            description: "Choose only one answer",
            answers: [
                StepAnswer(title: "📉 Lose weight", nextStepID: UUID()),
                StepAnswer(title: "👀 Maintain weight", nextStepID: UUID()),
                StepAnswer(title: "📈 Gain weight", nextStepID: UUID()),
                StepAnswer(title: "💪 Build weight", nextStepID: UUID()),
                StepAnswer(title: "💬 Something else", nextStepID: UUID()),
            ]
        )
    }
}
