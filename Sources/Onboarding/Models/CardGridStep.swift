//
//  File.swift
//  onboarding-ios
//

import Foundation

/// A grid of pickable cards, each showing an emoji or an image above its title.
struct CardGridStep: Sendable, Equatable, Hashable {
    let title: String
    let description: String?
    let buttonTitle: String
    let columns: Int
    let cards: [StepAnswer]
    /// Tapping a card submits it straight away, and no submit button is shown.
    let autoNavigate: Bool
    /// Where a card leads when it doesn't name a next step itself.
    let nextStepID: StepID?

    /// The chosen card, routed to this step's default when it carries no destination of its own.
    func answer(for card: StepAnswer) -> StepAnswer {
        var answer = card
        answer.nextStepID = card.nextStepID ?? nextStepID
        return answer
    }
}

// MARK: - Convert

extension CardGridStep {

    init(response: OnboardingStepResponse.CardGridStep) {
        self.init(
            title: response.title,
            description: response.description,
            buttonTitle: response.buttonTitle,
            columns: max(response.columns ?? 2, 1),
            cards: response.cards.map(StepAnswer.init(response:)),
            autoNavigate: response.autoNavigate ?? false,
            nextStepID: response.nextStepID
        )
    }
}
