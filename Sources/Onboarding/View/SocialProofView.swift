import SwiftUI
import CoreUI

struct SocialProofView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State var showContent = false
    @State var showStars = false
    @State var showMessage = false
    @State var showButton = false

    let step: SocialProofStep

    var body: some View {
        VStack(spacing: 0) {
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
            .padding(.horizontal, UIConstants.hScreenPadding)
            Spacer()
            Spacer()
            nextButton
                .padding(.horizontal, UIConstants.hScreenPadding)
                .revealBottomButton(showButton)
        }
        .padding(.vertical, UIConstants.vScreenPadding)
        .task {
            await animateIn()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text(localized("socialProof.welcomeHeadline"))
                .font(.headline)
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .tracking(1.2)
                .fontDesign(.rounded)
                .foregroundStyle(viewModel.colorPalette.accentColor)

            Text(localized("socialProof.welcomeSubheadline"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontDesign(.rounded)
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
                Text(localized("socialProof.userReview"))
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .fontDesign(.rounded)
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
            .frame(width: 40, height: 52)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
    }

    // MARK: - Message Section

    private var messageSection: some View {
        Text(localized("socialProof.message"))
            .font(.callout)
            .fontWeight(.regular)
            .italic()
            .fontDesign(.serif)
            .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.9))
            .multilineTextAlignment(.center)
            .lineSpacing(6)
            .padding(.horizontal, 8)
    }

    // MARK: - Button

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [makeAnswer()])
        } label: {
            Text(localized("socialProof.answerTitle"))
                .applyRippleEffect()
        }
        .primaryButtonStyleCompat(colorPalette: viewModel.colorPalette)
    }

    // MARK: - Helpers

    private func localized(_ key: String) -> String {
        viewModel.localize(key)
    }

    private func makeAnswer() -> StepAnswer {
        StepAnswer(
            title: localized("socialProof.answerTitle"),
            icon: nil,
            nextStepID: step.nextStepID,
            payload: nil
        )
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
        showButton = true
    }
}
