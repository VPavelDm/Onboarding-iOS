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

    init(response: OnboardingStepResponse.IntroStep, localizer: Localizer) {
        self.init(
            image: ImageMeta(response: response.image) ?? ImageMeta(imageType: .named(""), aspectRatioType: "fit"),
            title: response.title.localized(using: localizer),
            subtitle: response.subtitle?.localized(using: localizer),
            description: response.description?.localized(using: localizer),
            accentColor: response.accentColor.map { Color(hex: $0) },
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
