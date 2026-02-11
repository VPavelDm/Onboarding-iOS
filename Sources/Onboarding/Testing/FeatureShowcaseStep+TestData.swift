//
//  FeatureShowcaseStep+TestData.swift
//
//
//  Created by Pavel Vaitsikhouski on 10.02.26.
//

import SwiftUI

extension FeatureShowcaseStep {

    static func testData() -> Self {
        Self(
            image: ImageMeta(imageType: .named("feature_showcase"), aspectRatioType: "fit"),
            title: "Track smarter with AI",
            description: "Smart food tracking is here. Snap a photo and get instant nutrition info with AI\u{2014}no manual entry needed.",
            gradient: [Color(hex: "0A8754"), Color(hex: "065E3A"), Color(hex: "1A1A1A")],
            backgroundColor: Color(hex: "1A1A1A"),
            answer: StepAnswer(
                title: "Continue",
                nextStepID: StepID("next")
            )
        )
    }
}
