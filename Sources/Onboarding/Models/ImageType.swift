//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI

enum ImageType: Sendable, Equatable, Hashable {
    case named(String)
    case remote(URL)
}

struct ImageMeta: Sendable, Equatable, Hashable {
    var imageType: ImageType
    var aspectRationType: String

    var contentMode: ContentMode {
        switch aspectRationType {
        case "fill":
                .fill
        default:
                .fit
        }
    }
}

// MARK: - Convert

extension ImageMeta {

    init?(response: OnboardingStepResponse.ImageResponse) {
        guard let type = ImageType(response: response) else { return nil }
        self.init(imageType: type, aspectRationType: response.aspectRationType)
    }
}

extension ImageType {

    init?(response: OnboardingStepResponse.ImageResponse) {
        switch response.type {
        case "named":
            self = .named(response.value)
        case "remote":
            if let url = URL(string: response.value) {
                self = .remote(url)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}
