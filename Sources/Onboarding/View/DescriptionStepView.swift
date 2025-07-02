//
//  SwiftUIView.swift
//
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import SwiftUI
import CoreUI

struct DescriptionStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var isTitleVisible: Bool = false
    @State private var isDescriptionVisible: Bool = false
    @State private var isButtonVisible: Bool = false

    var step: DescriptionStep

    var body: some View {
        VStack {
            imageView
            VStack(spacing: .headingSpacing) {
                titleView
                descriptionView
                    .opacity(isDescriptionVisible ? 1 : 0)
            }
            .padding(.horizontal, .hScreenPadding)
            .frame(maxHeight: .infinity, alignment: .top)
            nextButton
                .padding(.horizontal, .hScreenPadding)
                .opacity(isButtonVisible ? 1 : 0)
        }
        .padding(.vertical, .vScreenPadding)
        .ignoresSafeArea(edges: .top)
        .task {
            withAnimation(.easeInOut.delay(2)) {
                isDescriptionVisible = true
            }
            withAnimation(.easeInOut.delay(3)) {
                isButtonVisible = true
            }
        }
    }

    @ViewBuilder
    private var imageView: some View {
        if let image = step.image {
            OnboardingImage(image: image, bundle: viewModel.configuration.bundle)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .aspectRatio(1.0, contentMode: .fit)
                .frame(maxWidth: .infinity)
        }
    }

    private var titleView: some View {
        Text(viewModel.delegate.format(string: step.title))
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .multilineTextAlignment(.center)
                .font(.headline)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
        }
    }

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

#Preview {
    MockOnboardingView()
}
