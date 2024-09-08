//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import Foundation

extension BinaryAnswerStep {

    static func testData() -> Self {
        Self(
            title: "What's your sex?",
            description: "Since the formula for an accurate calorie calculation differs based on sex, we need this information to calculate your daily calorie goal.",
            firstAnswer: StepAnswer(
                title: "Female",
                icon: "🚺",
                nextStepID: UUID()
            ),
            secondAnswer: StepAnswer(
                title: "Male",
                icon: "🚹",
                nextStepID: UUID()
            )
        )
    }
}
