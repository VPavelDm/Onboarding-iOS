//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

extension OneAnswerStep {

    static func testData(
        nextStepID: StepID = StepID("starting_point")
    ) -> Self {
        Self(
            title: "What's your main goal?",
            description: "Choose only one answer",
            answers: [
                StepAnswer(title: "📉 Lose weight", nextStepID: nextStepID),
                StepAnswer(title: "👀 Maintain weight", nextStepID: nextStepID),
                StepAnswer(title: "📈 Gain weight", nextStepID: nextStepID),
                StepAnswer(title: "💪 Build weight", nextStepID: nextStepID),
                StepAnswer(title: "💬 Something else", nextStepID: nextStepID),
            ]
        )
    }
}
