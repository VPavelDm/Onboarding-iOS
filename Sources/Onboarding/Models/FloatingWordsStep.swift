//
//  FloatingWordsStep.swift
//  onboarding-ios
//

import Foundation

struct FloatingWordsStep: Sendable, Equatable, Hashable {
    let centralWord: String
    let centralTranslation: String?
    let floatingWords: [String]
    let nextStepID: StepID?
}

// MARK: - Convert

extension FloatingWordsStep {

    init(response: OnboardingStepResponse.FloatingWordsStep) {
        self.init(
            centralWord: response.centralWord,
            centralTranslation: response.centralTranslation,
            floatingWords: response.floatingWords,
            nextStepID: response.nextStepID
        )
    }
}
