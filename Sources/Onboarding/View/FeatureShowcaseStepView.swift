import SwiftUI
import CoreUI

struct FeatureShowcaseStepView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    @State private var showImage = false
    @State private var showTitle = false
    @State private var showDescription = false
    @State private var showButton = false

    let step: FeatureShowcaseStep

    var body: some View {
        VStack(spacing: 0) {
            imageView
                .opacity(showImage ? 1 : 0)
                .offset(y: showImage ? 0 : 20)
            VStack(spacing: .headingSpacing) {
                titleView
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 20)
                descriptionView
                    .opacity(showDescription ? 1 : 0)
                    .offset(y: showDescription ? 0 : 20)
            }
            .padding(.horizontal, .hScreenPadding)
            .frame(maxHeight: .infinity, alignment: .top)
            nextButton
                .padding(.horizontal, .hScreenPadding)
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 20)
        }
        .padding(.bottom, .vScreenPadding)
        .ignoresSafeArea(edges: .top)
        .task {
            await animateIn()
        }
    }

    private var imageView: some View {
        OnboardingImage(image: step.image, bundle: viewModel.configuration.bundle)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
            .frame(maxWidth: .infinity)
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
                .font(.body)
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

    private func animateIn() async {
        try? await Task.sleep(for: .milliseconds(100))
        withAnimation(.easeOut(duration: 0.5)) {
            showImage = true
        }

        try? await Task.sleep(for: .milliseconds(200))
        withAnimation(.easeOut(duration: 0.4)) {
            showTitle = true
        }

        try? await Task.sleep(for: .milliseconds(200))
        withAnimation(.easeOut(duration: 0.4)) {
            showDescription = true
        }

        try? await Task.sleep(for: .milliseconds(200))
        withAnimation(.easeOut(duration: 0.4)) {
            showButton = true
        }
    }
}
