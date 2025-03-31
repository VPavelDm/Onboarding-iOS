//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 30.03.25.
//

import SwiftUI

struct NavigationStackContent<OuterScreen>: View where OuterScreen: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    
    var step: OnboardingStep?
    let outerScreen: (OnboardingOuterScreenCallbackParams) -> OuterScreen

    var body: some View {
        Group {
            switch step?.type {
            case .welcome(let welcomeStep):
                WelcomeView(step: welcomeStep)
            case .welcomeFade(let step):
                WelcomeFadeView(step: step, outerScreen: outerScreen)
            case .oneAnswer(let oneAnswerStep):
                OneAnswerView(step: oneAnswerStep)
            case .binaryAnswer(let binaryAnswerStep):
                BinaryAnswerView(step: binaryAnswerStep)
            case .multipleAnswer(let multipleAnswerStep):
                MultipleAnswerView(step: multipleAnswerStep)
            case .description(let descriptionStep):
                DescriptionStepView(step: descriptionStep)
            case .login:
                outerScreen((.login, handleOuterScreenCallback))
            case .custom:
                if let stepID = step?.id {
                    outerScreen((.custom(stepID), handleOuterScreenCallback))
                }
            case .prime(let step):
                PrimeStepView(step: step)
            case .progress(let step):
                ProgressStepView(step: step)
            case .timePicker(let step):
                TimePickerStepView(step: step)
            case .discountWheel(let step):
                DiscountWheelStepView(step: step)
            case .widget(let step):
                WidgetStepView(step: step)
            case .socialProof(let step):
                SocialProofView(step: step)
            case .enterName(let step):
                NameStepView(step: step)
            case .unknown, .none:
                EmptyView()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .removeBackground()
    }

    private func handleOuterScreenCallback() async {
        switch viewModel.currentStep?.type {
        case .custom(let stepAnswer):
            await viewModel.onAnswer(answers: [stepAnswer])
        case .login(let stepAnswer):
            await viewModel.onAnswer(answers: [stepAnswer])
        default:
            break
        }
    }
}
