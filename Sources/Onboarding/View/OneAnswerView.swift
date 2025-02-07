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

    var step: OneAnswerStep

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading) {
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
        AsyncButton {
            await viewModel.onAnswer(answers: [answer])
        } label: {
            Text(answer.title)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(AnswerButtonStyle())
    }
}

#Preview {
    OneAnswerView(step: .testData())
        .preferredColorScheme(.dark)
}
