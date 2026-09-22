import SwiftUI
import CoreUI

/// The score first, then the reviews it averages to. The list scrolls under the button rather than
/// above it: however many reviews a flow carries, the way on stays where the thumb already is.
struct ReviewsStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    let step: ReviewsStep

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headline
                    .padding(.top, 8)
                    .padding(.bottom, UIConstants.vScreenPadding)
                ratingBlock
                    .padding(.bottom, UIConstants.vScreenPadding)
                reviewCards
            }
            .padding(.horizontal, UIConstants.hScreenPadding)
            // Clears the floating button, so the last review can be read in full.
            .padding(.bottom, .scrollBottomInset)
        }
        .overlay(alignment: .bottomTrailing) {
            continueButton
        }
    }

    private var headline: some View {
        Text(localized(step.title))
            .font(.system(size: 32, weight: .bold))
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Rating

    private var ratingBlock: some View {
        HStack(spacing: 10) {
            laurel(.leading)
            VStack(spacing: 4) {
                stars(size: .starSize)
                ratingValue
                ratingCaption
            }
            laurel(.trailing)
        }
    }

    private func laurel(_ edge: HorizontalEdge) -> some View {
        Image(systemName: edge == .leading ? "laurel.leading" : "laurel.trailing")
            .font(.system(size: 96))
            .foregroundStyle(viewModel.colorPalette.accentColor)
    }

    private var ratingValue: some View {
        Text(verbatim: step.rating)
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .foregroundStyle(viewModel.colorPalette.textColor)
    }

    private var ratingCaption: some View {
        Text(localized(step.ratingCaption))
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    private func stars(size: CGFloat) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: size))
                    .foregroundStyle(viewModel.colorPalette.ratingStarColor)
            }
        }
    }

    // MARK: - Reviews

    private var reviewCards: some View {
        VStack(spacing: 12) {
            ForEach(step.reviews) { review in
                reviewCard(review)
            }
        }
    }

    private func reviewCard(_ review: ReviewsStep.Review) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(localized(review.title))
                .font(.headline.weight(.semibold))
                .foregroundStyle(viewModel.colorPalette.textColor)
            stars(size: .cardStarSize)
            Text(localized(review.body))
                .font(.callout)
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.85))
                .lineSpacing(2)
                .multilineTextAlignment(.leading)
            Text(verbatim: "— \(review.author)")
                .font(.caption)
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.5))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassBackground(cornerRadius: 18)
    }

    // MARK: - Button

    private var continueButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [answer])
        } label: {
            HStack(spacing: 6) {
                Text(localized(step.buttonTitle))
                    .font(.headline.weight(.semibold))
                Image(systemName: "arrow.right")
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(viewModel.colorPalette.primaryButtonForegroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(viewModel.colorPalette.accentColor)
            .clipShape(Capsule())
            .shadow(color: viewModel.colorPalette.accentColor.opacity(0.35), radius: 14, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.trailing, UIConstants.hScreenPadding)
        .padding(.bottom, 32)
    }

    private var answer: StepAnswer {
        StepAnswer(title: step.buttonTitle, icon: nil, nextStepID: step.nextStepID, payload: nil)
    }

    private func localized(_ key: String) -> String {
        viewModel.localize(key)
    }
}

private extension CGFloat {

    static let starSize: CGFloat = 15
    static let cardStarSize: CGFloat = 11
    static let scrollBottomInset: CGFloat = 110
}

// MARK: - Preview

#Preview {
    MockOnboardingView()
}
