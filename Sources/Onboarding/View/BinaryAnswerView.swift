//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import SwiftUI
import CoreUI

struct BinaryAnswerView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    var step: BinaryAnswerStep
    
    var body: some View {
        VStack(spacing: UIConstants.contentSpacing) {
            VStack(spacing: UIConstants.headingSpacing) {
                titleView
                descriptionView
            }
            HStack(spacing: UIConstants.buttonsSpacing) {
                firstAnswerButton
                secondAnswerButton
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.vertical, UIConstants.vScreenPadding)
        .padding(.horizontal, UIConstants.hScreenPadding)
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .font(.body)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .multilineTextAlignment(.center)
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
            .applyRippleEffect()
        }
        .binaryAnswerButtonStyleCompat()
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
            .applyRippleEffect()
        }
        .binaryAnswerButtonStyleCompat()
    }
}
