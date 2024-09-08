//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 08.09.24.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.colorPalette) private var colorPalette
    @EnvironmentObject private var viewModel: OnboardingViewModel

    var step: WelcomeStep

    var body: some View {
        VStack(spacing: 26) {
            ZStack {
                imageView
                imageGradientView
                    .rotationEffect(.radians(.pi))
                    .frame(maxHeight: .infinity, alignment: .top)
                imageGradientView
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
            VStack {
                titleView
                descriptionView
            }
            .padding(.horizontal)
            VStack {
                getStartedButton
                alreadyHaveAccountButton
            }
            .padding([.horizontal, .bottom])
        }
        .ignoresSafeArea(edges: [.top])
        .background(colorPalette.backgroundColor)
    }

    @ViewBuilder
    private var imageView: some View {
        if let image = step.image {
            OnboardingImage(image: image, bundle: viewModel.configuration.bundle)
        }
    }

    private var imageGradientView: some View {
        LinearGradient(
            colors: [
                colorPalette.backgroundColor.opacity(0),
                colorPalette.backgroundColor
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 50)
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(colorPalette.primaryTextColor)
    }

    private var descriptionView: some View {
        Text(step.description)
            .font(.body)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .foregroundStyle(colorPalette.secondaryTextColor)
    }

    private var getStartedButton: some View {
        Button {
            viewModel.onAnswer()
        } label: {
            Text("Get Started")
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    private var alreadyHaveAccountButton: some View {
        Button {} label: {
            Text("I Already Have an Account")
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

#Preview {
    OnboardingView(
        configuration: .testData(),
        outerScreen: { _ in Text("") },
        completion: { _ in }
    )
}
