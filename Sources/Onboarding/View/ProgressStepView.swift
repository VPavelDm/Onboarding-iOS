//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 18.09.24.
//

import SwiftUI

struct ProgressStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State var progress: CGFloat = 0
    @State var isButtonLoading: Bool = false
    @State var finishedProcessing: Bool = false

    var step: ProgressStep

    var body: some View {
        ScrollView {
            VStack(spacing: 64) {
                ProgressCircleView(duration: step.duration, progress: $progress, finished: finishedProcessing)
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
        .task {
            await viewModel.processAnswers(step: step)
            finishedProcessing = true
        }
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .foregroundStyle(viewModel.colorPalette.textColor)
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

    private var nextButton: some View {
        Button {
            isButtonLoading = true
            viewModel.onProgressButton()
        } label: {
            ZStack {
                Text(step.answer.title)
                    .opacity(isButtonLoading ? 0 : 1)
                ProgressView()
                    .tint(viewModel.colorPalette.primaryButtonForegroundColor)
                    .opacity(isButtonLoading ? 1 : 0)
            }
        }
        .primaryButtonStyleCompat(colorPalette: viewModel.colorPalette)
        .padding(.horizontal, UIConstants.hScreenPadding)
        .padding(.vertical, UIConstants.vScreenPadding)
        .disabled(progress != 100)
        .opacity(progress == 100 ? 1 : 0)
        .animation(.easeInOut, value: progress == 100)
    }
}

#if !os(Android)
#Preview {
    MockOnboardingView()
}
#endif
