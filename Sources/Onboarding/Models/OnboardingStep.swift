//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

struct OnboardingStep: Sendable, Equatable, Hashable {
    var id: UUID
    var type: OnboardingStepType
    var passedPercent: Double

    enum OnboardingStepType: Sendable, Equatable, Hashable {
        case welcome(WelcomeStep)
        case oneAnswer(OneAnswerStep)
        case binaryAnswer(BinaryAnswerStep)
        case multipleAnswer(MultipleAnswerStep)
        case description(DescriptionStep)
        case login(StepAnswer)
        case custom(StepAnswer)
        case prime(StepAnswer)
        case unknown
    }
}

// MARK: -

extension OnboardingStep {

    var isNotUnknown: Bool {
        if case OnboardingStepType.unknown = type {
            return false
        } else {
            return true
        }
    }
}

// MARK: - Convert

extension OnboardingStep {

    init?(response: OnboardingStepResponse) {
        let type: OnboardingStepType = switch response.type {
        case .welcome(let payload): .welcome(WelcomeStep(response: payload))
        case .oneAnswer(let payload): .oneAnswer(OneAnswerStep(response: payload))
        case .multipleAnswer(let payload): .multipleAnswer(MultipleAnswerStep(response: payload))
        case .description(let payload): .description(DescriptionStep(response: payload))
        case .binaryAnswer(let payload): .binaryAnswer(BinaryAnswerStep(response: payload))
        case .login(let payload): .login(StepAnswer(response: payload))
        case .custom(let payload): .custom(StepAnswer(response: payload))
        case .prime(let payload): .prime(StepAnswer(response: payload))
        default: .unknown
        }

        self.init(
            id: response.id,
            type: type,
            passedPercent: response.passedPercent
        )
    }
}
