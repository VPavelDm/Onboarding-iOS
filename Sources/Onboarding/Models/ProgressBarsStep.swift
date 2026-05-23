import Foundation

struct ProgressBarsStep: Sendable, Equatable, Hashable {
    var title: String
    var stepLabels: [String]
    var creditNumber: String?
    var creditDescription: [String]
    var answer: StepAnswer
}

extension ProgressBarsStep {

    init(response: OnboardingStepResponse.ProgressBarsStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            stepLabels: response.stepLabels.map { $0.localized(using: localizer) },
            creditNumber: response.creditNumber?.localized(using: localizer),
            creditDescription: response.creditDescription.map { $0.localized(using: localizer) },
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
