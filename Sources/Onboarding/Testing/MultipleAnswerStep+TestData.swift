//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import Foundation

extension MultipleAnswerStep {

    static func testData(
        nextStepID: StepID = StepID("challenges")
    ) -> Self {
        Self(
            title: "What challenges did you face?",
            description: "Choose at least one option",
            image: nil,
            buttonTitle: "Next",
            minAnswersAmount: 0,
            answers: [
                StepAnswer(title:  "🍟 Resting cravings", nextStepID: nextStepID),
                StepAnswer(title:  "✨ Staying motivated", nextStepID: nextStepID),
                StepAnswer(title:  "🥣 Reducing portion sizes", nextStepID: nextStepID),
                StepAnswer(title:  "🥗 Knowing what to eat", nextStepID: nextStepID),
                StepAnswer(title:  "⏰ Being too busy", nextStepID: nextStepID),
                StepAnswer(title:  "💭 Something else", nextStepID: nextStepID),
            ]
        )
    }
}
