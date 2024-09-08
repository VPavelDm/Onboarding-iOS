//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import Foundation

extension MultipleAnswerStep {

    static func testData(
        nextStepID: UUID = UUID(uuidString: "C34BD07B-CA60-41CE-8377-D749D4B196F4")!
    ) -> Self {
        Self(
            title: "What challenges did you face?",
            description: "Choose at least one option",
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
