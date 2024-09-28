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
            answer: StepAnswer(title: "Step")
        )
    }
}
