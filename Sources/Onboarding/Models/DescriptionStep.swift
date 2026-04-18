//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI

struct DescriptionStep: Sendable, Equatable, Hashable {
    let image: ImageMeta?
    let title: String
    let description: String?
    let answer: StepAnswer
}

// MARK: - Convert

extension DescriptionStep {

    init(response: OnboardingStepResponse.DescriptionStep, localizer: Localizer) {
        self.init(
            image: response.image.flatMap(ImageMeta.init),
            title: response.title.localized(using: localizer),
            description: response.description?.localized(using: localizer),
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
