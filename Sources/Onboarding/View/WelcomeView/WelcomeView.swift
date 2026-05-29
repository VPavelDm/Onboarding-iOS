//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 08.09.24.
//

import SwiftUI
import CoreUI

struct WelcomeView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    var step: WelcomeStep

    var body: some View {
        VStack(spacing: 26) {
            AnimatedImageView(step: step)
            VStack {
                getStartedButton
                if let answer = step.secondAnswer {
                    alreadyHaveAccountButton(answer: answer)
                }
            }
            .padding([.horizontal, .bottom])
        }
    }

    private var getStartedButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.firstAnswer])
        } label: {
            Text(step.firstAnswer.title)
                .applyRippleEffect()
        }
        .primaryButtonStyleCompat(colorPalette: viewModel.colorPalette)
    }

    private func alreadyHaveAccountButton(answer: StepAnswer) -> some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [answer])
        } label: {
            Text(answer.title)
                .applyRippleEffect()
        }
        .secondaryButtonStyleCompat(colorPalette: viewModel.colorPalette)
    }
}
