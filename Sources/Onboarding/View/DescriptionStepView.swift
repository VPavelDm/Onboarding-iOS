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
        ScrollView {
            VStack {
                imageView
                VStack(alignment: .leading, spacing: 12) {
                    if isTitleVisible {
                        titleView
                    }
                    if isDescriptionVisible {
                        descriptionView
                    }
                }
                .padding(.horizontal)
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom) {
            if isButtonVisible {
                nextButton
            }
        }
        .task {
            withAnimation {
                isTitleVisible = true
            }
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
                .frame(maxWidth: .infinity)
                .aspectRatio(contentMode: image.contentMode)
                .clipShape(BottomWaveShape())
        }
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .font(.headline)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding()
    }
}

#Preview {
    OnboardingView(
        configuration: .testData(),
        delegate: MockOnboardingDelegate(),
        colorPalette: .testData,
        outerScreen: { _ in }
    )
    .preferredColorScheme(.dark)
}
