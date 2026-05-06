//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 29.03.25.
//

import Foundation

struct SocialProofStep: Sendable, Hashable {
    let image: ImageMeta
    let welcomeHeadline: String
    let welcomeSubheadline: String
    let userReview: String
    let message: String
    let answer: StepAnswer
}

extension SocialProofStep {

    init(response: OnboardingStepResponse.SocialProofStep, localizer: Localizer) {
        self.init(
            image: ImageMeta(response: response.image) ?? ImageMeta(imageType: .named(""), aspectRatioType: "fit"),
            welcomeHeadline: response.welcomeHeadline.localized(using: localizer),
            welcomeSubheadline: response.welcomeSubheadline.localized(using: localizer),
            userReview: response.userReview.localized(using: localizer),
            message: response.message.localized(using: localizer),
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
