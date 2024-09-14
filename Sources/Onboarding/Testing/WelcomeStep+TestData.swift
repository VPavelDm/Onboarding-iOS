//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 08.09.24.
//

import Foundation

extension WelcomeStep {

    static func testData() -> Self {
        Self(
            title: "Welcome to YAZIO",
            description: "Let's make every day count!",
            emojis: ["🍎", "🥑", "🥒", "🧀", "🥕", "🥩"],
            firstAnswer: StepAnswer(
                title: "Get Started",
                nextStepID: StepID("challenges")
            ),
            secondAnswer: StepAnswer(
                title: "I Have Already an Account",
                nextStepID: StepID("login")
            )
        )
    }
}
