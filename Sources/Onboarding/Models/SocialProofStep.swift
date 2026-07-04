//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 29.03.25.
//

import Foundation

struct SocialProofStep: Sendable, Hashable {
    let image: ImageMeta
    let nextStepID: StepID?
}

extension SocialProofStep {

    init(response: OnboardingStepResponse.SocialProofStep) {
        self.init(
            image: ImageMeta(response: response.image) ?? ImageMeta(imageType: .named(""), aspectRatioType: "fit"),
            nextStepID: response.nextStepID
        )
    }
}
