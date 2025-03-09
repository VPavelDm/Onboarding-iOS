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

    var step: DescriptionStep

    var body: some View {
        ScrollView {
            VStack {
                imageView
                VStack(alignment: .leading, spacing: 12) {
                    titleView
                    descriptionView
                }
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom) {
            nextButton
        }
        .background(viewModel.colorPalette.backgroundColor)
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
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .font(.headline)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .padding(.horizontal)
        }
    }

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    DescriptionStepView(step: .testData())
        .environmentObject(OnboardingViewModel(
            configuration: .testData(),
            delegate: MockOnboardingDelegate(),
            colorPalette: .testData
        ))
        .preferredColorScheme(.dark)
}
