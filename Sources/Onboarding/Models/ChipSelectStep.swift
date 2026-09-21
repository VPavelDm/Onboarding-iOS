//
//  File.swift
//  onboarding-ios
//

import Foundation

/// A wrapping set of chips to pick several of, each showing an emoji or an image beside its title.
struct ChipSelectStep: Sendable, Equatable, Hashable {
    let title: String
    let description: String?
    let buttonTitle: String
    /// How many chips have to be picked before the step can be submitted.
    let minSelected: Int
    let chips: [StepAnswer]
    /// Where the step leads when the chips don't name a destination themselves.
    let nextStepID: StepID?

    /// The picked chips, routed to this step's default when they carry no destination of their own.
    func answers(for selected: [StepAnswer]) -> [StepAnswer] {
        selected.map { chip in
            var answer = chip
            answer.nextStepID = chip.nextStepID ?? nextStepID
            return answer
        }
    }
}

// MARK: - Convert

extension ChipSelectStep {

    init(response: OnboardingStepResponse.ChipSelectStep) {
        self.init(
            title: response.title,
            description: response.description,
            buttonTitle: response.buttonTitle,
            minSelected: max(response.minSelected ?? 1, 0),
            chips: response.chips.map(StepAnswer.init(response:)),
            nextStepID: response.nextStepID
        )
    }
}
