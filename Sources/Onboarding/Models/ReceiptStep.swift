import Foundation

struct ReceiptStep: Sendable, Equatable, Hashable {
    var items: [String]
    var nextStepID: StepID?
}

extension ReceiptStep {

    init(response: OnboardingStepResponse.ReceiptStep) {
        self.init(
            items: response.items.map { $0 },
            nextStepID: response.nextStepID
        )
    }
}
