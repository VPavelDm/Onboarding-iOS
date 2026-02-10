//
//  FeatureShowcaseStep+TestData.swift
//
//
//  Created by Pavel Vaitsikhouski on 10.02.26.
//

import Foundation

extension FeatureShowcaseStep {

    static func testData() -> Self {
        Self(
            image: ImageMeta(imageType: .named("feature_showcase"), aspectRatioType: "fill"),
            title: "Track smarter with AI",
            description: "Our AI-powered tracking helps you stay on top of your goals effortlessly.",
            answer: StepAnswer(
                title: "Continue",
                nextStepID: StepID("next")
            )
        )
    }
}
