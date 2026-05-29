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
    @State var isButtonVisible: Bool = false

    var step: OneAnswerStep

    private var shouldAutoNavigate: Bool {
        step.autoNavigateOnSingleAnswer
    }

    var body: some View {
        ScrollView {
            VStack(spacing: UIConstants.contentSpacing) {
                imageView
                VStack(spacing: UIConstants.headingSpacing) {
                    titleView
                    descriptionView
                }
                VStack(spacing: UIConstants.buttonsSpacing) {
                    ForEach(step.answers.indices, id: \.self) { index in
                        buttonView(answer: step.answers[index])
                    }
                }
            }
            .padding(.vertical, UIConstants.vScreenPadding)
            .padding(.horizontal, UIConstants.hScreenPadding)
        }
        .scrollContentBackground(.hidden)
        .bottomBar {
            if !shouldAutoNavigate && (selectedAnswer != nil || step.skip != nil) {
                nextButton
                    .padding(.horizontal, UIConstants.hScreenPadding)
                    .padding(.bottom, UIConstants.vScreenPadding)
            }
        }
        .animation(.easeInOut, value: selectedAnswer != nil)
    }

    @ViewBuilder
    private var imageView: some View {
        if let image = step.image {
            OnboardingImage(image: image, bundle: viewModel.configuration.bundle)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .frame(maxWidth: .infinity)
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
                .applyRippleEffect(alignment: .leading)
        } progress: {
            ProgressView()
                .frame(maxWidth: .infinity)
                .tint(viewModel.colorPalette.primaryButtonForegroundColor)
        }
        .answerButtonStyleCompat(colorPalette: viewModel.colorPalette, isSelected: selectedAnswer == answer)
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
        .animation(.easeInOut, value: selectedAnswer)
    }

    private func skipButton(skip: StepAnswer) -> some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [skip])
        } label: {
            Text(skip.title)
                .applyRippleEffect()
        }
        .secondaryButtonStyleCompat(colorPalette: viewModel.colorPalette)
    }
}

#if !os(Android)
#Preview {
    MockOnboardingView()
}
#endif
