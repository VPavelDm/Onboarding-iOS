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
            title: "Welcome to Lyncil",
            description: "Unleash Your Songwriting Potential with Lyncil",
            image: .named("womanWithTeleskope"),
            firstAnswer: StepAnswer(
                title: "Get Started",
                nextStepID: UUID()
            ),
            secondAnswer: StepAnswer(
                title: "I Have Already an Account",
                nextStepID: UUID()
            )
        )
    }
}
