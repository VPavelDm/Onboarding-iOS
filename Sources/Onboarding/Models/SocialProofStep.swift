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
    let message: String
    let answer: StepAnswer
}

extension SocialProofStep {

    init(response: OnboardingStepResponse.SocialProofStep) {
        self.init(
            image: ImageMeta(response: response.image),
            welcomeHeadline: response.welcomeHeadline,
            welcomeSubheadline: response.welcomeSubheadline,
            userReview: response.userReview,
            message: response.message,
            answer: StepAnswer(response: response.answer)
        )
    }
}
