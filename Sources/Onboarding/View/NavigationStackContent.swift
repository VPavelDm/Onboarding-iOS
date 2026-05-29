//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 30.03.25.
//

import SwiftUI

struct NavigationStackContent<CustomStepView>: View where CustomStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel
    
    var step: OnboardingStep?
    var customStepView: (CustomStepParams) -> CustomStepView

    var body: some View {
        Group {
            switch step?.type {
            case .welcome(let welcomeStep):
                WelcomeView(step: welcomeStep)
            case .oneAnswer(let oneAnswerStep):
                OneAnswerView(step: oneAnswerStep)
            case .binaryAnswer(let binaryAnswerStep):
                BinaryAnswerView(step: binaryAnswerStep)
            case .multipleAnswer(let multipleAnswerStep):
                MultipleAnswerView(step: multipleAnswerStep)
            case .description(let descriptionStep):
                DescriptionStepView(step: descriptionStep)
            case .enterValue(let step):
                EnterValueStepView(step: step)
            case .custom(let stepParams):
                customStepView(stepParams)
            case .welcomeFade(let step):
                WelcomeFadeView(step: step, customStepView: customStepView)
            case .progress(let step):
                ProgressStepView(step: step)
            case .widget(let step):
                WidgetStepView(step: step)
            case .socialProof(let step):
                SocialProofView(step: step)
            case .featureShowcase(let step):
                FeatureShowcaseStepView(step: step)
            case .intro(let step):
                IntroStepView(step: step)
            case .survivalFunnel(let step):
                SurvivalFunnelStepView(step: step)
            case .floatingWords(let step):
                FloatingWordsStepView(step: step)
            // Excluded from Android (Skip): wheel pickers (.wheel unavailable + custom drawing),
            // discount wheel (Confetti + SIMD), and MeshGradient-based steps.
            case .timePicker(let step):
                #if os(Android)
                EmptyView()
                #else
                TimePickerStepView(step: step)
                #endif
            case .discountWheel(let step):
                #if os(Android)
                EmptyView()
                #else
                DiscountWheelStepView(step: step)
                #endif
            case .heightPicker(let step):
                HeightPickerStepView(step: step)
            case .weightPicker(let step):
                WeightPickerStepView(step: step)
            case .agePicker(let step):
                AgePickerStepView(step: step)
            case .commitmentHold(let step):
                CommitmentHoldStepView(step: step)
            case .receipt(let step):
                ReceiptStepView(step: step)
            case .formula(let step):
                FormulaStepView(step: step)
            case .progressBars(let step):
                ProgressBarsStepView(step: step)
            case .milestoneTimeline(let step):
                MilestoneTimelineStepView(step: step)
            case .comparisonCards(let step):
                ComparisonCardsStepView(step: step)
            case .unknown, .none:
                EmptyView()
            }
        }
    }
}
