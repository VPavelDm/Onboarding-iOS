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
    let backgroundColor: Color
    let answer: StepAnswer
}

// MARK: - Convert

extension FeatureShowcaseStep {

    init(response: OnboardingStepResponse.FeatureShowcaseStep) {
        self.init(
            image: ImageMeta(response: response.image) ?? ImageMeta(imageType: .named(""), aspectRatioType: "fill"),
            title: response.title,
            description: response.description,
            backgroundColor: Color(hex: response.backgroundColor),
            answer: StepAnswer(response: response.answer)
        )
    }
}
