//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 28.09.24.
//

import Foundation

struct PrimeStep: Sendable, Equatable, Hashable {
    var title: String
    var description: String
    var answer: StepAnswer
    var refuseAnswer: StepAnswer
    var warning: RefuseWarning

    struct RefuseWarning: Sendable, Equatable, Hashable {
        var title: String
        var description: String
        var cancelButtonTitle: String
        var confirmButtonTitle: String
    }
}

// MARK: - Convert

extension PrimeStep {

    init(response: OnboardingStepResponse.PrimeStep) {
        self.init(
            title: response.title,
            description: response.description,
            answer: StepAnswer(response: response.answer),
            refuseAnswer: StepAnswer(response: response.refuseAnswer),
            warning: RefuseWarning(response: response.warning)
        )
    }
}

extension PrimeStep.RefuseWarning {

    init(response: OnboardingStepResponse.PrimeStep.RefuseWarning) {
        self.init(
            title: response.title,
            description: response.description,
            cancelButtonTitle: response.cancelButtonTitle,
            confirmButtonTitle: response.confirmButtonTitle
        )
    }
}
