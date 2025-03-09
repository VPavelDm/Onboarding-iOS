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

    init(response: OnboardingStepResponse.DescriptionStep) {
        var image: ImageMeta?
        if let imageResponse = response.image {
            image = ImageMeta(response: imageResponse)
        }
        self.init(
            image: image,
            title: response.title,
            description: response.description,
            answer: StepAnswer(response: response.answer)
        )
    }
}
