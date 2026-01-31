//
//  AgePickerStep+TestData.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.01.26.
//

import Foundation

extension AgePickerStep {

    static func testData(
        nextStepID: StepID = StepID("next")
    ) -> Self {
        Self(
            title: "How old are you?",
            description: "This helps us personalize your experience",
            answer: StepAnswer(
                title: "Continue",
                nextStepID: nextStepID
            )
        )
    }
}
