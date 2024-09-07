//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

struct OnboardingStep: Sendable, Equatable, Hashable {
    var id: UUID
    var nextStepID: UUID?
    var type: OnboardingStepType
    var maxStepsInChain: Int

    enum OnboardingStepType: Sendable, Equatable, Hashable {
        case oneAnswer(OneAnswerStep)
        case binaryAnswer(BinaryAnswerStep)
        case multipleAnswer(MultipleAnswerStep)
        case description(DescriptionStep)
        case login
        case custom
        case prime
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
        case .oneAnswer(let payload): .oneAnswer(OneAnswerStep(response: payload))
        case .multipleAnswer(let payload): .multipleAnswer(MultipleAnswerStep(response: payload))
        case .description(let payload): .description(DescriptionStep(response: payload))
        case .binaryAnswer(let payload): .binaryAnswer(BinaryAnswerStep(response: payload))
        case .login: .login
        case .custom: .custom
        case .prime: .prime
        default: .unknown
        }

        self.init(
            id: response.id,
            nextStepID: response.nextStepID,
            type: type,
            maxStepsInChain: response.maxStepsInChain
        )
    }
}
