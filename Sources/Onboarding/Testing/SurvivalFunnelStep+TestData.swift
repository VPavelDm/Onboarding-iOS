//
//  SurvivalFunnelStep+TestData.swift
//  onboarding-ios
//

import Foundation

extension SurvivalFunnelStep {

    static func testData() -> Self {
        Self(
            title: "Most learners quit before they get fluent.",
            description: "Out of every 100 people who start, only a few stick around.",
            caption: "You don't have to be one of the 94.",
            stages: [
                Stage(label: "Day 1",  count: 100, dropoffLabel: "60 quit by Day 7"),
                Stage(label: "Day 7",  count: 40,  dropoffLabel: "22 quit by Day 30"),
                Stage(label: "Day 30", count: 18,  dropoffLabel: "12 fizzle by Day 90"),
                Stage(label: "Day 90", count: 6,   dropoffLabel: nil)
            ],
            answer: StepAnswer(
                title: "Tell me how it's different",
                nextStepID: StepID("dropout_curve_preview")
            )
        )
    }
}
