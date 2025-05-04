//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 29.03.25.
//

import Foundation

struct EnterNameStep: Sendable, Hashable {
    var title: String
    var description: String?
    var answer: StepAnswer
}

// MARK: - Convert

extension EnterNameStep {

    init(response: OnboardingStepResponse.EnterNameStep) {
        self.title = response.title
        self.description = response.description
        self.answer = StepAnswer(response: response.answer)
    }
}
