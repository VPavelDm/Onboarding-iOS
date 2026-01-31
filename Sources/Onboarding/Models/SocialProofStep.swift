//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 29.03.25.
//

import Foundation

struct SocialProofStep: Sendable, Hashable {
    let image: ImageMeta?
    let welcomeHeadline: String
    let welcomeSubheadline: String
    let userReview: String
    let stats: [StatItem]
    let message: String
    let messageAuthor: String
    let answer: StepAnswer

    struct StatItem: Sendable, Hashable {
        let value: String
        let label: String
    }
}

extension SocialProofStep {

    init(response: OnboardingStepResponse.SocialProofStep, localizer: Localizer) {
        self.init(
            image: ImageMeta(response: response.image),
            welcomeHeadline: response.welcomeHeadline.localized(using: localizer),
            welcomeSubheadline: response.welcomeSubheadline.localized(using: localizer),
            userReview: response.userReview.localized(using: localizer),
            stats: response.stats.map { StatItem(value: $0.value.localized(using: localizer), label: $0.label.localized(using: localizer)) },
            message: response.message.localized(using: localizer),
            messageAuthor: response.messageAuthor.localized(using: localizer),
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
