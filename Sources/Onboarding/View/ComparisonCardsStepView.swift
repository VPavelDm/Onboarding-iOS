import SwiftUI
import CoreUI

struct ComparisonCardsStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State var appeared = false
    @State var showCTA = false

    let step: ComparisonCardsStep

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            header
            cardsRow
            Spacer()
            continueButton
        }
        .padding(.horizontal, UIConstants.hScreenPadding)
        .padding(.bottom, UIConstants.vScreenPadding)
        .task {
            appeared = true
            try? await Task.sleep(for: .seconds(ctaAppearDelay))
            showCTA = true
        }
    }

    /// Waits for `ComparisonWordCard`'s staggered fade to finish before revealing the CTA.
    private var ctaAppearDelay: Double {
        let fadingCount = max(step.items.count - 1, 0)
        let lastStaggerDelay = Double(max(fadingCount - 1, 0)) * ComparisonCardsAnimationConstants.perItemStagger
        return ComparisonCardsAnimationConstants.startDelay + lastStaggerDelay + ComparisonCardsAnimationConstants.fadeDuration
    }

    private var header: some View {
        VStack(spacing: UIConstants.headingSpacing) {
            titleView
            subtitleView
        }
    }

    private var titleView: some View {
        Text(localized("comparisonCards.title"))
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var subtitleView: some View {
        let text = localized("comparisonCards.subtitle")
        if !text.isEmpty {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
    }

    private var cardsRow: some View {
        HStack(spacing: 8) {
            ComparisonWordCard(
                label: localized("comparisonCards.leftLabel"),
                items: step.items,
                highlightedIndex: nil
            )
            .frame(maxWidth: .infinity)
            arrowImage
            ComparisonWordCard(
                label: localized("comparisonCards.rightLabel"),
                items: step.items,
                highlightedIndex: appeared ? step.highlightedIndex : nil
            )
            .frame(maxWidth: .infinity)
        }
    }

    private var arrowImage: some View {
        AdaptiveSymbol(systemName: "arrow.right", emoji: "→")
            .font(.headline)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
    }

    private var continueButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [makeAnswer()])
        } label: {
            Text(localized("comparisonCards.answerTitle"))
                .applyRippleEffect()
        }
        .primaryButtonStyleCompat(colorPalette: viewModel.colorPalette)
        .revealBottomButton(showCTA)
    }

    private func localized(_ key: String) -> String {
        viewModel.localize(key)
    }

    private func makeAnswer() -> StepAnswer {
        StepAnswer(
            title: localized("comparisonCards.answerTitle"),
            icon: nil,
            nextStepID: step.nextStepID,
            payload: nil
        )
    }
}

 struct ComparisonWordCard: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    let label: String
    let items: [String]
    let highlightedIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            labelView
            itemsList
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glassBackground(cornerRadius: 16)
    }

    private var labelView: some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .foregroundStyle(viewModel.colorPalette.accentColor)
            .tracking(1.5)
    }

    private var itemsList: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Text(viewModel.localize(item))
                    .font(.subheadline)
                    .foregroundStyle(viewModel.colorPalette.textColor)
                    .opacity(opacity(at: index))
                    .blur(radius: blur(at: index))
                    .animation(
                        .easeOut(duration: ComparisonCardsAnimationConstants.fadeDuration).delay(delay(at: index)),
                        value: highlightedIndex
                    )
            }
        }
    }

    private func opacity(at index: Int) -> Double {
        guard let highlightedIndex else { return 1 }
        return index == highlightedIndex ? 1 : ComparisonCardsAnimationConstants.dimmedOpacity
    }

    private func blur(at index: Int) -> CGFloat {
        guard let highlightedIndex else { return 0 }
        return index == highlightedIndex ? 0 : ComparisonCardsAnimationConstants.dimmedBlur
    }

    private func delay(at index: Int) -> Double {
        guard let highlightedIndex, index != highlightedIndex else { return 0 }
        let positionInFadeOrder = index < highlightedIndex ? index : index - 1
        return ComparisonCardsAnimationConstants.startDelay + Double(positionInFadeOrder) * ComparisonCardsAnimationConstants.perItemStagger
    }
}

private enum ComparisonCardsAnimationConstants {
    static let startDelay: Double = 0.4
    static let perItemStagger: Double = 0.3
    static let fadeDuration: Double = 0.7
    static let dimmedOpacity: Double = 0.18
    static let dimmedBlur: CGFloat = 1.2
}
