//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 08.09.24.
//

import Foundation

struct StepAnswer: Sendable, Equatable, Hashable {
    var title: String
    var icon: String?
    var nextStepID: StepID?
}

// MARK: - Convert

extension StepAnswer {

    init(response: OnboardingStepResponse.StepAnswer) {
        self.init(
            title: response.title,
            icon: response.icon,
            nextStepID: response.nextStepID
        )
    }
}
