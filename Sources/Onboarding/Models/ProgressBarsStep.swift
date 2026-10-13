import Foundation

struct ProgressBarsStep: Sendable, Equatable, Hashable {
    var stepLabels: [String]
    /// The laurelled credit line under the bars; off for a host with nothing to cite there.
    var showsCredit: Bool = true
    var nextStepID: StepID?
}

extension ProgressBarsStep {

    init(response: OnboardingStepResponse.ProgressBarsStep) {
        self.init(
            stepLabels: response.stepLabels.map { $0 },
            showsCredit: response.showsCredit ?? true,
            nextStepID: response.nextStepID
        )
    }
}
