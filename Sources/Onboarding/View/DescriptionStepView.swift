//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import SwiftUI

struct DescriptionStepView: View {
    @Environment(\.colorPalette) private var colorPalette
    @EnvironmentObject private var viewModel: OnboardingViewModel

    var step: DescriptionStep

    var body: some View {
        VStack(alignment: .leading) {
            imageView
            VStack(alignment: .leading, spacing: 12) {
                titleView
                descriptionView
            }
            Spacer()
            nextButton
        }
        .background(colorPalette.backgroundColor)
        .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder
    private var imageView: some View {
        if let image = step.image {
            OnboardingImage(image: image, bundle: viewModel.configuration.bundle)
                .frame(maxWidth: .infinity)
                .aspectRatio(1.0, contentMode: .fit)
                .clipShape(BottomWaveShape())
        }
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(colorPalette.primaryTextColor)
            .padding(.horizontal)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .font(.headline)
                .foregroundStyle(colorPalette.secondaryTextColor)
                .padding(.horizontal)
        }
    }

    private var nextButton: some View {
        Button {
            viewModel.onAnswer()
        } label: {
            Text("Next")
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    DescriptionStepView(step: .testData())
        .environmentObject(OnboardingViewModel(configuration: .testData(), completion: { _ in}))
}
