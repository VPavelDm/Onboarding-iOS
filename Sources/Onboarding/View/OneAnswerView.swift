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

    var step: OneAnswerStep

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    titleView
                    descriptionView
                }
                VStack(spacing: 12) {
                    ForEach(step.answers.indices, id: \.self) { index in
                        buttonView(answer: step.answers[index])
                    }
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                nextButton
                if let skip = step.skip {
                    skipButton(skip: skip)
                }
            }
            .padding()
            .background(viewModel.colorPalette.backgroundColor)
        }
        .padding(.top, .progressBarHeight + .progressBarBottomPadding)
        .background(viewModel.colorPalette.backgroundColor)
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .font(.headline)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
        }
    }

    private func buttonView(answer: StepAnswer) -> some View {
        Button {
            selectedAnswer = answer
        } label: {
            Text(answer.title)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(AnswerButtonStyle(isSelected: selectedAnswer == answer))
    }

    private var nextButton: some View {
        AsyncButton {
            if let selectedAnswer {
                await viewModel.onAnswer(answers: [selectedAnswer])
            }
        } label: {
            Text(step.buttonTitle)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(selectedAnswer == nil)
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
    OneAnswerView(step: .testData())
        .environmentObject(OnboardingViewModel(
            configuration: .testData(),
            delegate: MockOnboardingDelegate(),
            colorPalette: .testData
        ))
        .preferredColorScheme(.dark)
}
