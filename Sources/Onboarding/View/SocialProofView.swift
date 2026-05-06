import SwiftUI
import CoreUI

struct SocialProofView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    @State private var showContent = false
    @State private var showStars = false
    @State private var showMessage = false
    @State private var showButton = false

    let step: SocialProofStep

    var body: some View {
        VStack(spacing: 0) {
            imageView
            VStack(spacing: 32) {
                headerSection
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                ratingSection
                    .opacity(showStars ? 1 : 0)
                    .scaleEffect(showStars ? 1 : 0.9)

                messageSection
                    .opacity(showMessage ? 1 : 0)
                    .offset(y: showMessage ? 0 : 20)
            }
            .padding(.horizontal, .hScreenPadding)
            Spacer()
            Spacer()
            nextButton
                .padding(.horizontal, .hScreenPadding)
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 20)
        }
        .padding(.vertical, .vScreenPadding)
        .task {
            await animateIn()
        }
    }

    // MARK: - Image

    private var imageView: some View {
        OnboardingImage(image: step.image, bundle: viewModel.configuration.bundle)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
            .aspectRatio(1.0, contentMode: .fit)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text(step.welcomeHeadline)
                .font(.subheadline)
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .tracking(1.2)
                .apply { view in
                    if #available(iOS 16.1, *) {
                        view.fontDesign(.rounded)
                    }
                }
                .foregroundStyle(viewModel.colorPalette.accentColor)

            Text(step.welcomeSubheadline)
                .font(.title)
                .fontWeight(.bold)
                .apply { view in
                    if #available(iOS 16.1, *) {
                        view.fontDesign(.rounded)
                    }
                }
                .foregroundStyle(viewModel.colorPalette.textColor)
        }
        .multilineTextAlignment(.center)
    }

    // MARK: - Rating Section

    private var ratingSection: some View {
        HStack(spacing: 12) {
            laurelView
            VStack(spacing: 8) {
                starsView
                Text(step.userReview)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                    .apply { view in
                        if #available(iOS 16.1, *) {
                            view.fontDesign(.rounded)
                        }
                    }
            }
            laurelView
                .scaleEffect(x: -1, y: 1)
        }
    }

    private var starsView: some View {
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundStyle(viewModel.colorPalette.ratingStarColor)
                    .scaleEffect(showStars ? 1 : 0)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.6)
                            .delay(Double(index) * 0.08),
                        value: showStars
                    )
            }
        }
    }

    private var laurelView: some View {
        Image("laurel", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 52)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
    }

    // MARK: - Message Section

    private var messageSection: some View {
        Text(step.message)
            .font(.callout)
            .fontWeight(.regular)
            .italic()
            .apply { view in
                if #available(iOS 16.1, *) {
                    view.fontDesign(.serif)
                }
            }
            .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.9))
            .multilineTextAlignment(.center)
            .lineSpacing(6)
            .padding(.horizontal, 8)
    }

    // MARK: - Button

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    // MARK: - Animation

    private func animateIn() async {
        try? await Task.sleep(for: .milliseconds(100))
        withAnimation(.easeOut(duration: 0.5)) {
            showContent = true
        }

        try? await Task.sleep(for: .milliseconds(200))
        withAnimation(.easeOut(duration: 0.4)) {
            showStars = true
        }

        try? await Task.sleep(for: .milliseconds(400))
        withAnimation(.easeOut(duration: 0.4)) {
            showMessage = true
        }

        try? await Task.sleep(for: .milliseconds(200))
        withAnimation(.easeOut(duration: 0.4)) {
            showButton = true
        }
    }
}

#Preview {
    MockOnboardingView()
}
