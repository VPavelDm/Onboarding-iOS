import Foundation

struct CommitmentHoldStep: Sendable, Equatable, Hashable {
    var commitmentNumber: String
    var nextStepID: StepID?
}

extension CommitmentHoldStep {

    init(response: OnboardingStepResponse.CommitmentHoldStep, localizer: Localizer) {
        self.init(
            commitmentNumber: response.commitmentNumber,
            nextStepID: response.nextStepID
        )
    }
}
