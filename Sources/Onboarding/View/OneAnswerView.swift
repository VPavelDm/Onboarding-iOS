//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI

struct OneAnswerView: View {
    @Environment(\.colorPalette) private var colorPalette
    @EnvironmentObject private var viewModel: OnboardingViewModel

    var step: OneAnswerStep

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading) {
                    titleView
                    descriptionView
                }
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(step.answers.indices, id: \.self) { index in
                        buttonView(answer: step.answers[index])
                    }
                }
            }
            .padding()
        }
        .background(colorPalette.backgroundColor)
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(colorPalette.primaryTextColor)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .font(.headline)
                .foregroundStyle(colorPalette.secondaryTextColor)
        }
    }

    private func buttonView(answer: String) -> some View {
        Button {
            viewModel.onAnswer(answers: [answer])
        } label: {
            Text(answer)
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

#Preview {
    OneAnswerView(step: .testData())
}
