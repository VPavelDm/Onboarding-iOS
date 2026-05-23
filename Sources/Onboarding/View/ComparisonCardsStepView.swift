import SwiftUI
import CoreUI

struct ComparisonCardsStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var appeared = false

    let step: ComparisonCardsStep

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            header
            cardsRow
            Spacer()
            continueButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .onAppear { appeared = true }
    }

    private var header: some View {
        VStack(spacing: 12) {
            titleView
            subtitleView
        }
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var subtitleView: some View {
        if let subtitle = step.subtitle {
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
    }

    private var cardsRow: some View {
        HStack(spacing: 8) {
            ComparisonWordCard(card: step.leftCard, highlightedIndex: nil)
            arrowImage
            ComparisonWordCard(
                card: step.rightCard,
                highlightedIndex: appeared ? step.highlightedIndex : nil
            )
        }
    }

    private var arrowImage: some View {
        Image(systemName: "arrow.right")
            .font(.headline)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
    }

    private var continueButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle(colorPalette: viewModel.colorPalette))
    }
}

private struct ComparisonWordCard: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    let card: ComparisonCardsStep.Card
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
        Text(card.label)
            .font(.caption.weight(.semibold))
            .foregroundStyle(viewModel.colorPalette.accentColor)
            .tracking(1.5)
    }

    private var itemsList: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(card.items.enumerated()), id: \.offset) { index, item in
                Text(item)
                    .font(.subheadline)
                    .foregroundStyle(viewModel.colorPalette.textColor)
                    .opacity(opacity(at: index))
                    .blur(radius: blur(at: index))
                    .animation(
                        .easeOut(duration: 0.7).delay(delay(at: index)),
                        value: highlightedIndex
                    )
            }
        }
    }

    private func opacity(at index: Int) -> Double {
        guard let highlightedIndex else { return 1 }
        return index == highlightedIndex ? 1 : 0.18
    }

    private func blur(at index: Int) -> CGFloat {
        guard let highlightedIndex else { return 0 }
        return index == highlightedIndex ? 0 : 1.2
    }

    private func delay(at index: Int) -> Double {
        guard let highlightedIndex, index != highlightedIndex else { return 0 }
        let positionInFadeOrder = index < highlightedIndex ? index : index - 1
        return 0.4 + Double(positionInFadeOrder) * 0.3
    }
}
