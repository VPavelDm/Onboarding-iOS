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

    init(response: OnboardingStepResponse.SocialProofStep, bundle: Bundle) {
        self.init(
            image: ImageMeta(response: response.image),
            welcomeHeadline: response.welcomeHeadline.localized(bundle: bundle),
            welcomeSubheadline: response.welcomeSubheadline.localized(bundle: bundle),
            userReview: response.userReview.localized(bundle: bundle),
            stats: response.stats.map { StatItem(value: $0.value.localized(bundle: bundle), label: $0.label.localized(bundle: bundle)) },
            message: response.message.localized(bundle: bundle),
            messageAuthor: response.messageAuthor.localized(bundle: bundle),
            answer: StepAnswer(response: response.answer, bundle: bundle)
        )
    }
}
