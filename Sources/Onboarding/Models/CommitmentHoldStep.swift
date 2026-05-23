import Foundation

struct CommitmentHoldStep: Sendable, Equatable, Hashable {
    var title: String
    var subtitle: String?
    var commitmentPrefix: String?
    var commitmentNumber: String
    var commitmentSuffix: String?
    var commitmentFooter: String?
    var answer: StepAnswer
}

extension CommitmentHoldStep {

    init(response: OnboardingStepResponse.CommitmentHoldStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            subtitle: response.subtitle?.localized(using: localizer),
            commitmentPrefix: response.commitmentPrefix?.localized(using: localizer),
            commitmentNumber: response.commitmentNumber.localized(using: localizer),
            commitmentSuffix: response.commitmentSuffix?.localized(using: localizer),
            commitmentFooter: response.commitmentFooter?.localized(using: localizer),
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
