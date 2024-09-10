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
        AnimatedImageView()
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

    private var getStartedButton: some View {
        Button {
            viewModel.onAnswer(answers: [step.firstAnswer])
        } label: {
            Text(step.firstAnswer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    private var alreadyHaveAccountButton: some View {
        Button {
            viewModel.onAnswer(answers: [step.secondAnswer])
        } label: {
            Text(step.secondAnswer.title)
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
