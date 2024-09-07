//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI

struct DescriptionStep: Sendable, Equatable, Hashable {
    let image: ImageType?
    let title: String
    let description: String?
}

// MARK: - Convert

extension DescriptionStep {

    init(response: OnboardingStepResponse.DescriptionStep) {
        var imageType: ImageType?
        if let imageResponse = response.image {
            imageType = ImageType(response: imageResponse)
        }
        self.init(
            image: imageType,
            title: response.title,
            description: response.description
        )
    }
}
