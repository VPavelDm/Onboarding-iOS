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
    var branches: [String: StepID] = [:]
    var callback: @Sendable (UserAnswer, _ nextStepID: StepID?) async -> Void = { _, _ in }

    /// Advance to the next step.
    ///
    /// - Parameters:
    ///   - branch: Optional named branch. When provided and present in the
    ///     step's `branches` map, the matching step ID is used. Otherwise the
    ///     step's default `nextStepID` is used.
    ///   - payloads: User-answer payloads to record alongside the completion.
    public func callAsFunction(
        branch: String? = nil,
        payloads: [UserAnswer.Payload] = []
    ) async {
        let userAnswer = UserAnswer(onboardingStepID: currentStepID, payloads: payloads)
        let target = branch.flatMap { branches[$0] } ?? nextStepID
        await callback(userAnswer, target)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.currentStepID == rhs.currentStepID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(currentStepID)
    }
}
