//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import Foundation

struct TimePickerStep: Sendable, Equatable, Hashable {
    let title: String
    let answer: StepAnswer
}

// MARK: - Convert

extension TimePickerStep {

    init(response: OnboardingStepResponse.TimePickerStep, bundle: Bundle) {
        self.init(
            title: response.title.localized(bundle: bundle),
            answer: StepAnswer(response: response.answer, bundle: bundle)
        )
    }
}
