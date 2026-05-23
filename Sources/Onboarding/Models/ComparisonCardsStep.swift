import Foundation

struct ComparisonCardsStep: Sendable, Equatable, Hashable {
    var items: [String]
    var highlightedIndex: Int
    var nextStepID: StepID?
}

extension ComparisonCardsStep {

    init(response: OnboardingStepResponse.ComparisonCardsStep, localizer: Localizer) {
        self.init(
            items: response.items.map { $0.localized(using: localizer) },
            highlightedIndex: response.highlightedIndex,
            nextStepID: response.nextStepID
        )
    }
}
