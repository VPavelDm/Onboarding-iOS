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
        case progress(ProgressStep)
        case timePicker(TimePickerStep)
        case discountWheel(DiscountWheelStep)
        case unknown

        var title: String? {
            switch self {
            case .welcome(let welcomeStep):
                welcomeStep.title
            case .oneAnswer(let oneAnswerStep):
                oneAnswerStep.title
            case .binaryAnswer(let binaryAnswerStep):
                binaryAnswerStep.title
            case .multipleAnswer(let multipleAnswerStep):
                multipleAnswerStep.title
            case .description(let descriptionStep):
                descriptionStep.title
            case .login(let stepAnswer):
                stepAnswer.title
            case .custom(let stepAnswer):
                stepAnswer.title
            case .prime(let stepAnswer):
                stepAnswer.title
            case .progress(let progressStep):
                progressStep.title
            case .timePicker(let timePickerStep):
                timePickerStep.title
            case .discountWheel(let step):
                step.title
            case .unknown:
                nil
            }
        }
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
        case .progress(let payload): .progress(ProgressStep(response: payload))
        case .timePicker(let payload): .timePicker(TimePickerStep(response: payload))
        case .discountWheel(let payload): .discountWheel(DiscountWheelStep(response: payload))
        default: .unknown
        }

        self.init(
            id: response.id,
            type: type,
            passedPercent: response.passedPercent
        )
    }
}
