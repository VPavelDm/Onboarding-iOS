//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 27.09.24.
//

import Foundation

extension DiscountWheelStep {

    static func testData() -> Self {
        DiscountWheelStep(
            title: "Spin to Win Your Prime Discount",
            spinButtonTitle: "🔥 Power Up",
            spinFootnote: "Press and hold to spin.\nRelease when your heart is ready!",
            successTitle: "🥳 Wooohooo\nyou won 75% discount!",
            successDescription: "It is a one-time deal, so don't miss it!",
            answer: StepAnswer(title: "Step")
        )
    }
}
