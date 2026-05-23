import Foundation

struct ProgressBarsStep: Sendable, Equatable, Hashable {
    var stepLabels: [String]
    var nextStepID: StepID?
}

extension ProgressBarsStep {

    init(response: OnboardingStepResponse.ProgressBarsStep, localizer: Localizer) {
        self.init(
            stepLabels: response.stepLabels.map { $0.localized(using: localizer) },
            nextStepID: response.nextStepID
        )
    }
}
