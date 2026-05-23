import Foundation

struct MilestoneTimelineStep: Sendable, Equatable, Hashable {
    var title: String
    var subtitle: String?
    var floatingLabel: String?
    var milestones: [Milestone]
    var answer: StepAnswer

    struct Milestone: Sendable, Equatable, Hashable {
        var label: String
        var xRatio: Double
        var delay: Double
    }
}

extension MilestoneTimelineStep {

    init(response: OnboardingStepResponse.MilestoneTimelineStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            subtitle: response.subtitle?.localized(using: localizer),
            floatingLabel: response.floatingLabel?.localized(using: localizer),
            milestones: response.milestones.map {
                Milestone(
                    label: $0.label.localized(using: localizer),
                    xRatio: $0.xRatio,
                    delay: $0.delay
                )
            },
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
