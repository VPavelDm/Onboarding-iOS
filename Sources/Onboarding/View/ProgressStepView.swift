//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 18.09.24.
//

import SwiftUI

struct ProgressStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State var progress: CGFloat = 0
    @State private var isButtonLoading: Bool = false

    var step: ProgressStep

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(spacing: 64) {
                    ProgressCircleView(duration: 15, progress: $progress)
                    VStack(spacing: 32) {
                        titleView
                        stepsView
                    }
                }
                .padding(.top, 64)
                .padding(.horizontal, 32)
            }
            .scrollIndicators(.hidden)
            nextButton
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
        }
        .padding(.top, .progressBarHeight + .progressBarBottomPadding)
        .background(.black)
        .task {
            await viewModel.processAnswers(step: step)
        }
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .foregroundStyle(.black)
    }

    private var nextButton: some View {
        Button {
            isButtonLoading = true
            viewModel.onProgressButton()
        } label: {
            ZStack {
                Text(step.answer.title).opacity(isButtonLoading ? 0 : 1)
                ProgressView()
                    .tint(.accentColor)
                    .opacity(isButtonLoading ? 1 : 0)
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(progress != 100)
    }
}

#Preview {
    MockOnboardingView()
}
