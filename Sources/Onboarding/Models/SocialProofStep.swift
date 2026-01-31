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

    init(response: OnboardingStepResponse.SocialProofStep) {
        self.init(
            image: ImageMeta(response: response.image),
            welcomeHeadline: response.welcomeHeadline,
            welcomeSubheadline: response.welcomeSubheadline,
            userReview: response.userReview,
            stats: response.stats.map { StatItem(value: $0.value, label: $0.label) },
            message: response.message,
            messageAuthor: response.messageAuthor,
            answer: StepAnswer(response: response.answer)
        )
    }
}
