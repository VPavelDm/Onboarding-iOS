//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 08.09.24.
//

import SwiftUI
import CoreUI

struct WelcomeView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

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
        .background(viewModel.colorPalette.backgroundColor)
    }

    private var getStartedButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.firstAnswer])
        } label: {
            Text(step.firstAnswer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    private func alreadyHaveAccountButton(answer: StepAnswer) -> some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [answer])
        } label: {
            Text(answer.title)
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

#Preview {
    OnboardingView(
        configuration: .testData(),
        delegate: MockOnboardingDelegate(),
        colorPalette: .testData
    )
    .preferredColorScheme(.dark)
    .background(Color.red)
}
