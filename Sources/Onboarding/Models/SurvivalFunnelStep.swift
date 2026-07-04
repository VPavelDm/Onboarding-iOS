//
//  SurvivalFunnelStep.swift
//  onboarding-ios
//

import Foundation

struct SurvivalFunnelStep: Sendable, Equatable, Hashable {
    let stages: [Stage]
    let nextStepID: StepID?

    struct Stage: Sendable, Equatable, Hashable {
        let label: String
        let count: Int
        let dropoffLabel: String?
    }
}

// MARK: - Convert

extension SurvivalFunnelStep {

    init(response: OnboardingStepResponse.SurvivalFunnelStep) {
        self.init(
            stages: response.stages.map { Stage(response: $0) },
            nextStepID: response.nextStepID
        )
    }
}

extension SurvivalFunnelStep.Stage {

    init(response: OnboardingStepResponse.SurvivalFunnelStep.Stage) {
        self.init(
            label: response.label,
            count: response.count,
            dropoffLabel: response.dropoffLabel
        )
    }
}
