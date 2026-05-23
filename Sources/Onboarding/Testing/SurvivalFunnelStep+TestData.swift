//
//  SurvivalFunnelStep+TestData.swift
//  onboarding-ios
//

import Foundation

extension SurvivalFunnelStep {

    static func testData() -> Self {
        Self(
            stages: [
                Stage(label: "Day 1",  count: 100, dropoffLabel: "60 quit by Day 7"),
                Stage(label: "Day 7",  count: 40,  dropoffLabel: "22 quit by Day 30"),
                Stage(label: "Day 30", count: 18,  dropoffLabel: "12 fizzle by Day 90"),
                Stage(label: "Day 90", count: 6,   dropoffLabel: nil)
            ],
            nextStepID: StepID("dropout_curve_preview")
        )
    }
}
