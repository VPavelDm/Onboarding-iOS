//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 18.09.24.
//

import SwiftUI
import CoreUI

struct ProgressStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State var progress: CGFloat = 0

    var step: ProgressStep

    var body: some View {
        ScrollView {
            VStack(spacing: 64) {
                ProgressCircleView(duration: step.duration, progress: $progress)
                VStack(spacing: 2 * UIConstants.contentSpacing) {
                    VStack(spacing: UIConstants.headingSpacing) {
                        titleView
                        descriptionView
                    }
                    stepsView
                }
            }
            .padding(.vertical, UIConstants.vScreenPadding)
            .padding(.horizontal, UIConstants.hScreenPadding)
        }
        .scrollIndicators(.hidden)
        .bottomBar {
            nextButton
        }
    }

    private var titleView: some View {
        Text(viewModel.localize(step.title))
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .foregroundStyle(viewModel.colorPalette.textColor)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(viewModel.localize(description))
                .font(.body)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
    }

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(viewModel.localize(step.answer.title))
                .applyRippleEffect()
        } progress: {
            ProgressView()
                .tint(viewModel.colorPalette.primaryButtonForegroundColor)
        }
        .primaryButtonStyleCompat(colorPalette: viewModel.colorPalette)
        .padding(.horizontal, UIConstants.hScreenPadding)
        .padding(.vertical, UIConstants.vScreenPadding)
        .disabled(progress != 100)
        .revealBottomBarButton(progress == 100)
    }
}

#if !os(Android)
#Preview {
    MockOnboardingView()
}
#endif
