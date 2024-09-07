//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

enum ImageType: Sendable, Equatable, Hashable {
    case named(String)
    case remote(URL)
}

// MARK: - Convert

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
