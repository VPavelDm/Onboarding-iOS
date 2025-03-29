//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 29.03.25.
//

import Foundation

struct SocialProofStep: Sendable, Hashable {
    let title: String
    let image: ImageMeta?
    let palmBranchTitle: String
    let palmBranchDescription: String
    let userReview: String
    let answer: StepAnswer
}

extension SocialProofStep {

    init(response: OnboardingStepResponse.SocialProofStep) {
        self.init(
            title: response.title,
            image: ImageMeta(response: response.image),
            palmBranchTitle: response.palmBranchTitle,
            palmBranchDescription: response.palmBranchDescription,
            userReview: response.userReview,
            answer: StepAnswer(response: response.answer)
        )
    }
}
