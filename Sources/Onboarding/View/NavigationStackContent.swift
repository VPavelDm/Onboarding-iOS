//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 30.03.25.
//

import SwiftUI

struct NavigationStackContent<CustomStepView>: View where CustomStepView: View {
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
                WelcomeFadeView(step: step)
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
            case .timePicker(let step):
                TimePickerStepView(step: step)
            case .discountWheel(let step):
                DiscountWheelStepView(step: step)
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
            case .cardGrid(let step):
                CardGridStepView(step: step)
            case .notifications(let step):
                NotificationsStepView(step: step)
            case .numberStepper(let step):
                NumberStepperStepView(step: step)
            case .chipSelect(let step):
                ChipSelectStepView(step: step)
            case .unknown, .none:
                Color.clear
            }
        }
    }
}
