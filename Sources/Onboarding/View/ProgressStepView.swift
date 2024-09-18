//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 18.09.24.
//

import SwiftUI

struct ProgressStepView: View {
    @Environment(\.colorPalette) var colorPalette
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State var progress: CGFloat = 0

    var step: ProgressStep

    var body: some View {
        VStack {
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
            nextButton
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
        }
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .foregroundStyle(colorPalette.primaryTextColor)
    }

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [])
        } label: {
            Text("Continue")
        }
        .buttonStyle(PrimaryButtonStyle())
        .opacity(progress == 100 ? 1 : 0)
        .animation(.easeInOut, value: progress == 100)
    }
}

#Preview {
    ProgressStepView(step: .testData())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.testData.backgroundColor)
}
