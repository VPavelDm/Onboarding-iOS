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
        VStack(spacing: 32) {
            imageView
            Spacer()
            VStack(alignment: .leading, spacing: 12) {
                titleView
                descriptionView
                    .opacity(isDescriptionVisible ? 1 : 0)
            }
            .padding(.horizontal, 20)
            Spacer()
            Spacer()
            nextButton
                .padding(.horizontal, 20)
                .opacity(isButtonVisible ? 1 : 0)
        }
        .padding(.vertical, 32)
        .ignoresSafeArea(edges: .top)
        .task {
            withAnimation(.easeInOut.delay(2)) {
                isDescriptionVisible = true
            }
            withAnimation(.easeInOut.delay(4)) {
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
