//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import SwiftUI
import CoreUI

struct BinaryAnswerView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    var step: BinaryAnswerStep
    
    var body: some View {
        VStack(alignment: .leading, spacing: .contentSpacing) {
            VStack(alignment: .leading, spacing: .headingSpacing) {
                titleView
                descriptionView
            }
            HStack(spacing: .buttonsSpacing) {
                firstAnswerButton
                secondAnswerButton
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.vertical, .vScreenPadding)
        .padding(.horizontal, .hScreenPadding)
        .background(viewModel.colorPalette.anyBackgroundView)
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.white)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    private var firstAnswerButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.firstAnswer])
        } label: {
            VStack {
                if let icon = step.firstAnswer.icon {
                    Text(icon)
                        .font(.system(size: 32))
                }
                Text(step.firstAnswer.title)
            }
        }
        .buttonStyle(BinaryAnswerButtonStyle())
    }

    private var secondAnswerButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.secondAnswer])
        } label: {
            VStack {
                if let icon = step.secondAnswer.icon {
                    Text(icon)
                        .font(.system(size: 32))
                }
                Text(step.secondAnswer.title)
            }
        }
        .buttonStyle(BinaryAnswerButtonStyle())
    }
}
