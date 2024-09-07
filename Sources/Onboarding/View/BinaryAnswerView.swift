//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import SwiftUI

struct BinaryAnswerView: View {
    @Environment(\.colorPalette) private var colorPalette
    @EnvironmentObject private var viewModel: OnboardingViewModel

    var step: BinaryAnswerStep
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading) {
                titleView
                descriptionView
            }
            HStack(spacing: 16) {
                firstAnswerButton
                secondAnswerButton
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
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

    private var firstAnswerButton: some View {
        Button {
            viewModel.onAnswer(answers: [step.firstAnswer.text])
        } label: {
            VStack {
                if let icon = step.firstAnswer.icon {
                    Text(icon)
                        .font(.system(size: 32))
                }
                Text(step.firstAnswer.text)
            }
        }
        .buttonStyle(BinaryAnswerButtonStyle())
    }

    private var secondAnswerButton: some View {
        Button {
            viewModel.onAnswer(answers: [step.secondAnswer.text])
        } label: {
            VStack {
                if let icon = step.secondAnswer.icon {
                    Text(icon)
                        .font(.system(size: 32))
                }
                Text(step.secondAnswer.text)
            }
        }
        .buttonStyle(BinaryAnswerButtonStyle())
    }
}

#Preview {
    BinaryAnswerView(step: .testData())
        .environmentObject(OnboardingViewModel(configuration: .testData(), completion: { _ in}))
}
