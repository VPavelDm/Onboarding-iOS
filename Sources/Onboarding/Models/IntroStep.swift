//
//  IntroStep.swift
//

import SwiftUI

struct IntroStep: Sendable, Equatable, Hashable {
    let image: ImageMeta
    let title: String
    let subtitle: String?
    let description: String?
    let accentColor: Color?
    let answer: StepAnswer
}

// MARK: - Convert

extension IntroStep {

    init(response: OnboardingStepResponse.IntroStep) {
        self.init(
            image: ImageMeta(response: response.image) ?? ImageMeta(imageType: .named(""), aspectRatioType: "fit"),
            title: response.title,
            subtitle: response.subtitle,
            description: response.description,
            accentColor: response.accentColor.map { Color(hex: $0) },
            answer: StepAnswer(response: response.answer)
        )
    }
}
