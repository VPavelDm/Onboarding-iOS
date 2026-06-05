//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI
import CoreUI

struct OneAnswerView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State var selectedAnswer: StepAnswer?
    @State var revealedButtons = 0

    var step: OneAnswerStep

    private var shouldAutoNavigate: Bool {
        step.autoNavigateOnSingleAnswer
    }

    private var isNextButtonVisible: Bool {
        selectedAnswer != nil || step.skip != nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: UIConstants.contentSpacing) {
                VStack(spacing: UIConstants.headingSpacing) {
                    titleView
                    descriptionView
                }
                VStack(spacing: UIConstants.buttonsSpacing) {
                    ForEach(step.answers.indices, id: \.self) { index in
                        buttonView(answer: step.answers[index])
                            .androidStaggeredAppear(visible: revealedButtons > index)
                    }
                }
                .androidStaggeredReveal(count: step.answers.count, revealed: $revealedButtons)
            }
            .padding(.vertical, UIConstants.vScreenPadding)
            .padding(.horizontal, UIConstants.hScreenPadding)
        }
        .scrollContentBackground(.hidden)
        .bottomBar {
            if !shouldAutoNavigate {
                nextButton
                    .revealBottomBarButton(isNextButtonVisible)
            }
        }
    }

    private var titleView: some View {
        Text(step.title)
            .multilineTextAlignment(.center)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .padding(.horizontal, UIConstants.titlePadding)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
        }
    }

    private func buttonView(answer: StepAnswer) -> some View {
        AsyncButton {
            if shouldAutoNavigate {
                await viewModel.onAnswer(answers: [answer])
            } else {
                selectedAnswer = answer
            }
        } label: {
            Text(answer.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .applyRippleEffect()
        } progress: {
            ProgressView()
                .frame(maxWidth: .infinity)
                .tint(viewModel.colorPalette.primaryButtonForegroundColor)
        }
        .answerButtonStyleCompat(
            colorPalette: viewModel.colorPalette,
            isSelected: selectedAnswer == answer
        )
    }

    private var nextButton: some View {
        AsyncButton {
            if let selectedAnswer {
                await viewModel.onAnswer(answers: [selectedAnswer])
            } else if let skip = step.skip {
                await viewModel.onAnswer(answers: [skip])
            }
        } label: {
            Text(step.buttonTitle)
                .applyRippleEffect()
        }
        .primaryButtonStyleCompat(colorPalette: viewModel.colorPalette)
        .disabled(selectedAnswer == nil && step.skip == nil)
        .padding(.horizontal, UIConstants.hScreenPadding)
        .padding(.bottom, UIConstants.vScreenPadding)
    }
}

#if !os(Android)
#Preview {
    MockOnboardingView()
}
#endif
