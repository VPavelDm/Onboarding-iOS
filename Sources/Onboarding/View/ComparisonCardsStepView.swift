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
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .task {
            appeared = true
            try? await Task.sleep(for: .seconds(ctaAppearDelay))
            withAnimation(.easeOut(duration: 0.4)) {
                showCTA = true
            }
        }
    }

    /// Matches `ComparisonWordCard`'s fade timing — 0.4 start + 0.3 per-position stagger + 0.7 fade duration.
    private var ctaAppearDelay: Double {
        let fadingCount = max(step.items.count - 1, 0)
        let lastStaggerDelay = Double(max(fadingCount - 1, 0)) * 0.3
        return 0.4 + lastStaggerDelay + 0.7
    }

    private var header: some View {
        VStack(spacing: 12) {
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
        Image(systemName: "arrow.right")
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
        .opacity(showCTA ? 1 : 0)
        .offset(y: showCTA ? 0 : 16)
    }

    private func localized(_ key: String) -> String {
        viewModel.localizer.localize(key)
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

#if !os(Android)
#Preview {
    let sampleStep = ComparisonCardsStep(
        items: [
            "die Erfahrung",
            "entscheiden",
            "trotzdem",
            "die Gewohnheit",
            "verbessern"
        ],
        highlightedIndex: 2,
        nextStepID: nil
    )
    let viewModel = OnboardingViewModel(
        configuration: .testData(),
        delegate: MockOnboardingDelegate(onAnswerCallback: {}),
        colorPalette: .testData
    )
    return ComparisonCardsStepView(step: sampleStep)
        .environment(viewModel)
        .background(MeshGradientBackground())
        .preferredColorScheme(.dark)
}
#endif
