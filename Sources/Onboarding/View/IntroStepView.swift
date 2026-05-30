//
//  IntroStepView.swift
//

import SwiftUI
import CoreUI

struct IntroStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    let step: IntroStep

    @State var showImage = false
    @State var showTitle = false
    @State var showSubtitle = false
    @State var showBody = false
    @State var showButton = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            imageView
                .opacity(showImage ? 1 : 0)
                .scaleEffect(showImage ? 1 : 0.92)

            Spacer(minLength: 24)

            VStack(spacing: 10) {
                titleView
                    .opacity(showTitle ? 1 : 0)

                if step.subtitle != nil {
                    subtitleView
                        .opacity(showSubtitle ? 1 : 0)
                }

                divider
                    .padding(.vertical, 12)
                    .opacity(showSubtitle ? 1 : 0)

                if step.description != nil {
                    descriptionView
                        .opacity(showBody ? 1 : 0)
                }
            }

            Spacer(minLength: 24)

            nextButton
                .opacity(showButton ? 1 : 0)
        }
        .padding(.vertical, UIConstants.vScreenPadding)
        .padding(.horizontal, UIConstants.hScreenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView.ignoresSafeArea())
        .task { await runEntryAnimations() }
    }

    // MARK: - Image

    private var imageView: some View {
        OnboardingImage(image: step.image, bundle: viewModel.configuration.bundle)
            .aspectRatio(contentMode: step.image.contentMode)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
    }

    // MARK: - Text

    private var titleView: some View {
        Text(viewModel.delegate.format(string: step.title))
            .font(.system(size: 32, weight: .bold))
            .tracking(-0.4)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var subtitleView: some View {
        if let subtitle = step.subtitle {
            Text(subtitle)
                .font(.system(size: 15, weight: .regular, design: .serif))
                .italic()
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .font(.system(size: 16, design: .serif))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.6))
                .fixedSizeCompat(horizontal: false, vertical: true)
        }
    }

    private var divider: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(viewModel.colorPalette.textColor.opacity(0.15))
                .frame(height: 1)
            Image(systemName: "diamond.fill")
                .font(.system(size: 8))
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.4))
            Rectangle()
                .fill(viewModel.colorPalette.textColor.opacity(0.15))
                .frame(height: 1)
        }
        .frame(maxWidth: 220)
    }

    // MARK: - Button

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
                .applyRippleEffect()
        }
        .primaryButtonStyleCompat(colorPalette: viewModel.colorPalette)
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundView: some View {
        if let accent = step.accentColor {
            LinearGradient(
                colors: [accent.opacity(0.25), .clear],
                startPoint: .top,
                endPoint: .center
            )
        } else {
            Color.clear
        }
    }

    // MARK: - Animation

    private func runEntryAnimations() async {
        withAnimation(.easeOut(duration: 0.6)) { showImage = true }
        try? await Task.sleep(for: .milliseconds(250))

        withAnimation(.easeOut(duration: 0.4)) { showTitle = true }
        try? await Task.sleep(for: .milliseconds(180))

        withAnimation(.easeOut(duration: 0.4)) { showSubtitle = true }
        try? await Task.sleep(for: .milliseconds(180))

        withAnimation(.easeOut(duration: 0.4)) { showBody = true }
        try? await Task.sleep(for: .milliseconds(220))

        withAnimation(.easeInOut(duration: 0.4)) { showButton = true }
    }
}

#if !os(Android)
#Preview {
    NavigationStack {
        MockOnboardingView()
    }
}
#endif
