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
        case featureShowcase(FeatureShowcaseStep)
        case intro(IntroStep)
        case enterValue(EnterValueStep)
        case heightPicker(HeightPickerStep)
        case weightPicker(WeightPickerStep)
        case agePicker(AgePickerStep)
        case custom(CustomStepParams)
        case survivalFunnel(SurvivalFunnelStep)
        case floatingWords(FloatingWordsStep)
        case commitmentHold(CommitmentHoldStep)
        case receipt(ReceiptStep)
        case formula(FormulaStep)
        case progressBars(ProgressBarsStep)
        case milestoneTimeline(MilestoneTimelineStep)
        case comparisonCards(ComparisonCardsStep)
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
        case .welcomeFade(let payload): .welcomeFade(WelcomeFadeStep(response: payload))
        case .oneAnswer(let payload): .oneAnswer(OneAnswerStep(response: payload))
        case .multipleAnswer(let payload): .multipleAnswer(MultipleAnswerStep(response: payload))
        case .description(let payload): .description(DescriptionStep(response: payload))
        case .binaryAnswer(let payload): .binaryAnswer(BinaryAnswerStep(response: payload))
        case .progress(let payload): .progress(ProgressStep(response: payload))
        case .timePicker(let payload): .timePicker(TimePickerStep(response: payload))
        case .discountWheel(let payload): .discountWheel(DiscountWheelStep(response: payload))
        case .widget(let payload): .widget(WidgetStep(response: payload))
        case .socialProof(let payload): .socialProof(SocialProofStep(response: payload))
        case .featureShowcase(let payload): .featureShowcase(FeatureShowcaseStep(response: payload))
        case .intro(let payload): .intro(IntroStep(response: payload))
        case .enterValue(let payload): .enterValue(EnterValueStep(response: payload))
        case .heightPicker(let payload): .heightPicker(HeightPickerStep(response: payload))
        case .weightPicker(let payload): .weightPicker(WeightPickerStep(response: payload))
        case .agePicker(let payload): .agePicker(AgePickerStep(response: payload))
        case .custom(let payload):
            .custom(
                CustomStepParams(
                    currentStepID: response.id,
                    nextStepID: payload?.nextStepID,
                    branches: payload?.branches ?? [:]
                )
            )
        case .survivalFunnel(let payload): .survivalFunnel(SurvivalFunnelStep(response: payload))
        case .floatingWords(let payload): .floatingWords(FloatingWordsStep(response: payload))
        case .commitmentHold(let payload): .commitmentHold(CommitmentHoldStep(response: payload))
        case .receipt(let payload): .receipt(ReceiptStep(response: payload))
        case .formula(let payload): .formula(FormulaStep(response: payload))
        case .progressBars(let payload): .progressBars(ProgressBarsStep(response: payload))
        case .milestoneTimeline(let payload): .milestoneTimeline(MilestoneTimelineStep(response: payload))
        case .comparisonCards(let payload): .comparisonCards(ComparisonCardsStep(response: payload))
        default: .unknown
        }

        self.init(
            id: response.id,
            type: type
        )
    }
}
