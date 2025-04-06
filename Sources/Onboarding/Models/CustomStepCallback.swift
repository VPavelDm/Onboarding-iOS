//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 06.04.25.
//

import Foundation

public struct CustomStepParams: Sendable, Hashable {
    public var currentStepID: StepID
    var nextStepID: StepID?
    var callback: @Sendable (UserAnswer, _ nextStepID: StepID?) async -> Void = { _, _ in }

    public func callAsFunction(payloads: [UserAnswer.Payload] = []) async -> Void {
        let userAnswer = UserAnswer(onboardingStepID: currentStepID, payloads: payloads)
        await callback(userAnswer, nextStepID)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.currentStepID == rhs.currentStepID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(currentStepID)
    }
}
