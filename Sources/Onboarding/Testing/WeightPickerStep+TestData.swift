//
//  WeightPickerStep+TestData.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.01.26.
//

import Foundation

extension WeightPickerStep {

    static func testData(
        nextStepID: StepID = StepID("next")
    ) -> Self {
        Self(
            title: "What's your weight?",
            description: "This helps us personalize your experience",
            metricUnit: "kg",
            imperialUnit: "lbs",
            answer: StepAnswer(
                title: "Continue",
                nextStepID: nextStepID
            )
        )
    }
}
