//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI
import CoreUI

struct OneAnswerView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var selectedAnswer: StepAnswer?
    @State private var isButtonVisible: Bool = false

    var step: OneAnswerStep

    private var shouldAutoNavigate: Bool {
        step.autoNavigateOnSingleAnswer
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .contentSpacing) {
                VStack(spacing: .headingSpacing) {
                    titleView
                    descriptionView
                }
                VStack(spacing: .buttonsSpacing) {
                    ForEach(step.answers.indices, id: \.self) { index in
                        buttonView(answer: step.answers[index])
                    }
                }
            }
            .padding(.vertical, .vScreenPadding)
            .padding(.horizontal, .hScreenPadding)
        }
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .bottom) {
            if !shouldAutoNavigate && (selectedAnswer != nil || step.skip != nil) {
                nextButton
                    .padding(.horizontal, .hScreenPadding)
                    .padding(.bottom, .vScreenPadding)
            }
        }
        .animation(.easeInOut, value: selectedAnswer != nil)
    }

    private var titleView: some View {
        Text(step.title)
            .multilineTextAlignment(.center)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .padding(.horizontal, .titlePadding)
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
        } progress: {
            ProgressView()
                .frame(maxWidth: .infinity)
                .tint(viewModel.colorPalette.primaryButtonForegroundColor)
        }
        .buttonStyle(AnswerButtonStyle(isSelected: selectedAnswer == answer))
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
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(selectedAnswer == nil && step.skip == nil)
        .animation(.easeInOut, value: selectedAnswer)
    }

    private func skipButton(skip: StepAnswer) -> some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [skip])
        } label: {
            Text(skip.title)
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

#Preview {
    MockOnboardingView()
}
