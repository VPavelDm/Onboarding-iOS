//
//  SurvivalFunnelStep.swift
//  onboarding-ios
//

import Foundation

struct SurvivalFunnelStep: Sendable, Equatable, Hashable {
    let title: String
    let description: String?
    let caption: String?
    let stages: [Stage]
    let answer: StepAnswer

    struct Stage: Sendable, Equatable, Hashable {
        let label: String
        let count: Int
        let dropoffLabel: String?
    }
}

// MARK: - Convert

extension SurvivalFunnelStep {

    init(response: OnboardingStepResponse.SurvivalFunnelStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            description: response.description?.localized(using: localizer),
            caption: response.caption?.localized(using: localizer),
            stages: response.stages.map { Stage(response: $0, localizer: localizer) },
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}

extension SurvivalFunnelStep.Stage {

    init(response: OnboardingStepResponse.SurvivalFunnelStep.Stage, localizer: Localizer) {
        self.init(
            label: response.label.localized(using: localizer),
            count: response.count,
            dropoffLabel: response.dropoffLabel?.localized(using: localizer)
        )
    }
}
