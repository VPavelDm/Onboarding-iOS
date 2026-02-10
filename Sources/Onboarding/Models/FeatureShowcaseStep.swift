//
//  FeatureShowcaseStep.swift
//
//
//  Created by Pavel Vaitsikhouski on 10.02.26.
//

import SwiftUI

struct FeatureShowcaseStep: Sendable, Equatable, Hashable {
    let image: ImageMeta
    let title: String
    let description: String?
    let answer: StepAnswer
}

// MARK: - Convert

extension FeatureShowcaseStep {

    init(response: OnboardingStepResponse.FeatureShowcaseStep, localizer: Localizer) {
        self.init(
            image: ImageMeta(response: response.image) ?? ImageMeta(imageType: .named(""), aspectRatioType: "fill"),
            title: response.title.localized(using: localizer),
            description: response.description?.localized(using: localizer),
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
