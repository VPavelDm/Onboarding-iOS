//
//  HeightPickerStep+TestData.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.01.26.
//

import Foundation

extension HeightPickerStep {

    static func testData(
        nextStepID: StepID = StepID("next")
    ) -> Self {
        Self(
            title: "What's your height?",
            description: "This helps us personalize your experience",
            answer: StepAnswer(
                title: "Continue",
                nextStepID: nextStepID
            )
        )
    }
}
