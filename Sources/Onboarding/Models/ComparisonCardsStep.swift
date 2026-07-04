import Foundation

struct ComparisonCardsStep: Sendable, Equatable, Hashable {
    var items: [String]
    var highlightedIndex: Int
    var nextStepID: StepID?
}

extension ComparisonCardsStep {

    init(response: OnboardingStepResponse.ComparisonCardsStep) {
        self.init(
            items: response.items.map { $0 },
            highlightedIndex: response.highlightedIndex,
            nextStepID: response.nextStepID
        )
    }
}
