//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import Foundation

@MainActor
public protocol OnboardingDelegate {
    func format(string: String) -> String
    func onAnswer(userAnswer: UserAnswer, allAnswers: [UserAnswer]) async
    func routing(forStepID stepID: StepID) async -> StepRouting
}

/// How the onboarding flow controller should handle entering a step.
///
/// Returned from `OnboardingDelegate.routing(forStepID:)` *before* the step is
/// rendered, so a `.skip` decision means the step is never entered at all.
public enum StepRouting: Sendable {
    /// Render the step as usual.
    case show

    /// Skip without rendering. For custom steps, the target is resolved by
    /// looking up `branch` in the step's `branches` map; if `branch` is nil
    /// or not found, the step's default `nextStepID` is used.
    case skip(branch: String? = nil)
}

public extension OnboardingDelegate {

    func format(string: String) -> String {
        string
    }

    func routing(forStepID stepID: StepID) async -> StepRouting { .show }
}
