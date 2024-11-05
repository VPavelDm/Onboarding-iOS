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
            features: ["No Ads", "AI-Powered Translations and Examples", "Advanced Vocabulary Lists", "Exclusive Exercises"],
            answer: StepAnswer(title: "Apply Voucher")
        )
    }
}
