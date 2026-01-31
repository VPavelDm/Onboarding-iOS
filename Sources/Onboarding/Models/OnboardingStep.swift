//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

struct OnboardingStep: Sendable, Equatable, Hashable {
    var id: StepID
    var type: OnboardingStepType

    enum OnboardingStepType: Sendable, Equatable, Hashable {
        case welcome(WelcomeStep)
        case welcomeFade(WelcomeFadeStep)
        case oneAnswer(OneAnswerStep)
        case binaryAnswer(BinaryAnswerStep)
        case multipleAnswer(MultipleAnswerStep)
        case description(DescriptionStep)
        case progress(ProgressStep)
        case timePicker(TimePickerStep)
        case discountWheel(DiscountWheelStep)
        case widget(WidgetStep)
        case socialProof(SocialProofStep)
        case enterValue(EnterValueStep)
        case custom(CustomStepParams)
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

    init?(response: OnboardingStepResponse, bundle: Bundle) {
        let type: OnboardingStepType = switch response.type {
        case .welcome(let payload): .welcome(WelcomeStep(response: payload, bundle: bundle))
        case .welcomeFade(let payload): .welcomeFade(WelcomeFadeStep(response: payload, bundle: bundle))
        case .oneAnswer(let payload): .oneAnswer(OneAnswerStep(response: payload, bundle: bundle))
        case .multipleAnswer(let payload): .multipleAnswer(MultipleAnswerStep(response: payload, bundle: bundle))
        case .description(let payload): .description(DescriptionStep(response: payload, bundle: bundle))
        case .binaryAnswer(let payload): .binaryAnswer(BinaryAnswerStep(response: payload, bundle: bundle))
        case .progress(let payload): .progress(ProgressStep(response: payload, bundle: bundle))
        case .timePicker(let payload): .timePicker(TimePickerStep(response: payload, bundle: bundle))
        case .discountWheel(let payload): .discountWheel(DiscountWheelStep(response: payload, bundle: bundle))
        case .widget(let payload): .widget(WidgetStep(response: payload, bundle: bundle))
        case .socialProof(let payload): .socialProof(SocialProofStep(response: payload, bundle: bundle))
        case .enterValue(let payload): .enterValue(EnterValueStep(response: payload, bundle: bundle))
        case .custom(let payload): .custom(CustomStepParams(currentStepID: response.id, nextStepID: payload?.nextStepID))
        default: .unknown
        }

        self.init(
            id: response.id,
            type: type
        )
    }
}
