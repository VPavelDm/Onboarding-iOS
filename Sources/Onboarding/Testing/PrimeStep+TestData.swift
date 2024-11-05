//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 28.09.24.
//

import Foundation

extension PrimeStep {

    static func testData() -> PrimeStep {
        PrimeStep(
            title: "💎 Your One-Time Offer",
            description: "75% OFF FOREVER",
            answer: StepAnswer(title: "Apply Voucher"),
            refuseAnswer: StepAnswer(title: "Refuse Voucher")
        )
    }
}
