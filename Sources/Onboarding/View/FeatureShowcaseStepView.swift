import SwiftUI
import CoreUI

struct FeatureShowcaseStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State var showImage = false
    @State var showBottomSection = false
    @State var showTitle = false
    @State var showDescription = false
    @State var showButton = false

    let step: FeatureShowcaseStep

    var body: some View {
        VStack(spacing: 0) {
            topSection
            bottomSection
        }
        .task {
            try? await Task.sleep(for: .milliseconds(500))
            await animateIn()
        }
    }

    // MARK: - Top Section

    private var topSection: some View {
        VStack(spacing: 24) {
            imageView
                .opacity(showImage ? 1 : 0)
                .scaleEffect(showImage ? 1 : 0.85)
            textContent
                .offset(y: showBottomSection ? 0 : 40)
                .opacity(showBottomSection ? 1 : 0)
            Spacer(minLength: 0)
        }
        .layoutPriorityCompat(65)
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        buttonContent
            .background {
                step.backgroundColor
                    .ignoresSafeArea()
            }
    }

    // MARK: - Text Content

    private var textContent: some View {
        VStack(spacing: UIConstants.headingSpacing) {
            titleView
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 16)
            descriptionView
                .opacity(showDescription ? 1 : 0)
                .offset(y: showDescription ? 0 : 16)
        }
        .padding(.horizontal, UIConstants.hScreenPadding)
        .padding(.vertical, 24)
    }

    // MARK: - Button Content

    private var buttonContent: some View {
        nextButton
            .padding(.horizontal, UIConstants.hScreenPadding)
            .padding(.bottom, UIConstants.vScreenPadding)
            .revealBottomButton(showButton)
    }

    // MARK: - Image

    private var imageView: some View {
        OnboardingImage(image: step.image, bundle: viewModel.configuration.bundle)
            .aspectRatio(contentMode: step.image.contentMode)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 40)
            .padding(.top, 60)
    }

    // MARK: - Title

    private var titleView: some View {
        Text(viewModel.localize(step.title))
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
            .fixedSizeCompat(horizontal: false, vertical: true)
    }

    // MARK: - Description

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(viewModel.localize(description))
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .fixedSizeCompat(horizontal: false, vertical: true)
        }
    }

    // MARK: - Button

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(viewModel.localize(step.answer.title))
                .applyRippleEffect()
        }
        .primaryButtonStyleCompat(colorPalette: viewModel.colorPalette)
    }

    // MARK: - Animation

    private func animateIn() async {
        try? await Task.sleep(for: .milliseconds(100))
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showImage = true
        }

        try? await Task.sleep(for: .milliseconds(300))
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            showBottomSection = true
        }

        try? await Task.sleep(for: .milliseconds(150))
        withAnimation(.easeOut(duration: 0.4)) {
            showTitle = true
        }

        try? await Task.sleep(for: .milliseconds(150))
        withAnimation(.easeOut(duration: 0.4)) {
            showDescription = true
        }

        try? await Task.sleep(for: .milliseconds(150))
        showButton = true
    }
}

#if !os(Android)
#Preview {
    MockOnboardingView()
        .background(
            LinearGradient(colors: [.red, .orange], startPoint: .bottom, endPoint: .top)
        )
}
#endif
