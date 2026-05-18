//
//  FloatingWordsStep.swift
//  onboarding-ios
//

import Foundation

struct FloatingWordsStep: Sendable, Equatable, Hashable {
    let title: String
    let description: String?
    let caption: String?
    let centralWord: String
    let centralTranslation: String?
    let floatingWords: [String]
    let answer: StepAnswer
}

// MARK: - Convert

extension FloatingWordsStep {

    init(response: OnboardingStepResponse.FloatingWordsStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            description: response.description?.localized(using: localizer),
            caption: response.caption?.localized(using: localizer),
            centralWord: response.centralWord,
            centralTranslation: response.centralTranslation,
            floatingWords: response.floatingWords,
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
