//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 18.09.24.
//

import Foundation

struct ProgressStep: Sendable, Equatable, Hashable {
    var title: String
    var steps: [String]
}

// MARK: - Convert

extension ProgressStep {

    init(response: OnboardingStepResponse.ProgressStep) {
        self.init(
            title: response.title,
            steps: response.steps
        )
    }
}
