//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 18.09.24.
//

import SwiftUI

struct ProgressStepView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    @State var progress: CGFloat = 0
    @State private var isButtonLoading: Bool = false
    @State private var finishedProcessing: Bool = false

    var step: ProgressStep

    var body: some View {
        ScrollView {
            VStack(spacing: 64) {
                ProgressCircleView(duration: step.duration, progress: $progress, finished: finishedProcessing)
                VStack(spacing: .contentSpacing) {
                    VStack(spacing: .headingSpacing) {
                        titleView
                        descriptionView
                    }
                    stepsView
                }
            }
            .padding(.vertical, .vScreenPadding)
            .padding(.horizontal, .hScreenPadding)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
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
            .foregroundStyle(.white)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .font(.headline)
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
        .buttonStyle(PrimaryButtonStyle())
        .padding(.horizontal, .hScreenPadding)
        .padding(.vertical, .vScreenPadding)
        .disabled(progress != 100)
        .opacity(progress == 100 ? 1 : 0)
        .animation(.easeInOut, value: progress == 100)
    }
}

#Preview {
    MockOnboardingView()
}
