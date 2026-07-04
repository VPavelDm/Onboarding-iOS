import Foundation

struct MilestoneTimelineStep: Sendable, Equatable, Hashable {
    var milestones: [Milestone]
    var nextStepID: StepID?

    struct Milestone: Sendable, Equatable, Hashable {
        var label: String
        var xRatio: Double
        var delay: Double
    }
}

extension MilestoneTimelineStep {

    init(response: OnboardingStepResponse.MilestoneTimelineStep) {
        self.init(
            milestones: response.milestones.map {
                Milestone(
                    label: $0.label,
                    xRatio: $0.xRatio,
                    delay: $0.delay
                )
            },
            nextStepID: response.nextStepID
        )
    }
}
