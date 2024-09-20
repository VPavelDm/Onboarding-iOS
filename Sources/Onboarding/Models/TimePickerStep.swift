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

    init(response: OnboardingStepResponse.TimePickerStep) {
        self.init(
            title: response.title,
            answer: StepAnswer(response: response.answer)
        )
    }
}
