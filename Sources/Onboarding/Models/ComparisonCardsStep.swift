import Foundation

struct ComparisonCardsStep: Sendable, Equatable, Hashable {
    var title: String
    var subtitle: String?
    var leftCard: Card
    var rightCard: Card
    var highlightedIndex: Int?
    var answer: StepAnswer

    struct Card: Sendable, Equatable, Hashable {
        var label: String
        var items: [String]
    }
}

extension ComparisonCardsStep {

    init(response: OnboardingStepResponse.ComparisonCardsStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            subtitle: response.subtitle?.localized(using: localizer),
            leftCard: Card(
                label: response.leftCard.label.localized(using: localizer),
                items: response.leftCard.items.map { $0.localized(using: localizer) }
            ),
            rightCard: Card(
                label: response.rightCard.label.localized(using: localizer),
                items: response.rightCard.items.map { $0.localized(using: localizer) }
            ),
            highlightedIndex: response.highlightedIndex,
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
