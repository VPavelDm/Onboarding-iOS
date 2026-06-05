import SwiftUI

struct CommitmentHoldStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State var isCommitted = false
    @State var hapticTrigger = 0

    let step: CommitmentHoldStep

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            header
            commitmentCard
            Spacer()
            holdButton
            holdHint
        }
        .padding(.horizontal, UIConstants.hScreenPadding)
        .padding(.bottom, UIConstants.vScreenPadding)
        .sensoryFeedback(feedbackType: .success, trigger: hapticTrigger)
    }

    private var header: some View {
        VStack(spacing: UIConstants.headingSpacing) {
            titleView
            subtitleView
        }
        .multilineTextAlignment(.center)
    }

    private var titleView: some View {
        Text(localized("commitmentHold.title"))
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
    }

    @ViewBuilder
    private var subtitleView: some View {
        let text = localized("commitmentHold.subtitle")
        if !text.isEmpty {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
        }
    }

    private var commitmentCard: some View {
        CommitmentCardView(
            prefix: localized("commitmentHold.prefix"),
            number: viewModel.format(string: step.commitmentNumber),
            suffix: localized("commitmentHold.suffix"),
            footer: localized("commitmentHold.footer")
        )
    }

    private var holdButton: some View {
        CommitmentHoldButton(
            isCommitted: isCommitted,
            onCommit: completeCommitment
        )
    }

    private var holdHint: some View {
        Text(viewModel.localizer.localize("commitmentHold.hint"))
            .font(.callout)
            .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.65))
            .opacity(isCommitted ? 0 : 1)
            .animation(.easeOut(duration: 0.25), value: isCommitted)
    }

    private func localized(_ key: String) -> String {
        viewModel.localizer.localize(key)
    }

    private func makeAnswer() -> StepAnswer {
        StepAnswer(
            title: localized("commitmentHold.answerTitle"),
            icon: nil,
            nextStepID: step.nextStepID,
            payload: nil
        )
    }

    private func completeCommitment() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
            isCommitted = true
        }
        hapticTrigger += 1
        Task {
            try? await Task.sleep(for: .milliseconds(1400))
            await viewModel.onAnswer(answers: [makeAnswer()])
        }
    }
}

 struct CommitmentCardView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    let prefix: String
    let number: String
    let suffix: String
    let footer: String

    var body: some View {
        VStack(spacing: 8) {
            prefixText
            numberText
            suffixText
            footerText
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 28)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .glassBackground(cornerRadius: 24)
    }

    @ViewBuilder
    private var prefixText: some View {
        if !prefix.isEmpty {
            Text(prefix)
                .font(.title3)
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.85))
        }
    }

    private var numberText: some View {
        Text(number)
            .font(.system(size: 56, weight: .bold, design: .rounded))
            .monospacedDigitCompat()
            .foregroundStyle(viewModel.colorPalette.accentColor)
    }

    @ViewBuilder
    private var suffixText: some View {
        if !suffix.isEmpty {
            Text(suffix)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(viewModel.colorPalette.textColor)
        }
    }

    @ViewBuilder
    private var footerText: some View {
        if !footer.isEmpty {
            Text(footer)
                .font(.title3)
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.85))
        }
    }
}

 struct CommitmentHoldButton: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    let isCommitted: Bool
    let onCommit: () -> Void

    @State var progress: Double = 0
    @State var isPressing = false

    private let holdDuration: Double = 1.8

    var body: some View {
        ZStack {
            trackCircle
            progressCircle
            innerCircle
        }
        .scaleEffect(isPressing && !isCommitted ? 0.94 : 1.0)
        .animation(.snappy, value: isPressing)
        .contentShapeCompat(Circle())
        .holdToCommit(
            duration: holdDuration,
            perform: onCommit,
            onPressingChanged: handlePressingChanged
        )
    }

    private var trackCircle: some View {
        Circle()
            .stroke(viewModel.colorPalette.textColor.opacity(0.16), lineWidth: 5)
            .frame(width: 126, height: 126)
    }

    private var progressCircle: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(
                viewModel.colorPalette.accentColor,
                style: StrokeStyle(lineWidth: 5, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .frame(width: 126, height: 126)
    }

    private var innerCircle: some View {
        ZStack {
            innerFill
            innerLabel
        }
    }

    private var innerFill: some View {
        Circle()
            .fill(
                isCommitted
                    ? viewModel.colorPalette.accentColor
                    : viewModel.colorPalette.textColor.opacity(0.10)
            )
            .frame(width: 102, height: 102)
            .overlay {
                Circle().strokeBorder(viewModel.colorPalette.textColor.opacity(0.22), lineWidth: 1)
            }
    }

    @ViewBuilder
    private var innerLabel: some View {
        if isCommitted {
            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(viewModel.colorPalette.primaryButtonForegroundColor)
                .transition(.scale.combined(with: .opacity))
        } else {
            Text(viewModel.localizer.localize("commitmentHold.hold"))
                .font(.subheadline.weight(.heavy))
                .tracking(2.5)
                .foregroundStyle(viewModel.colorPalette.textColor)
        }
    }

    private func handlePressingChanged(_ pressing: Bool) {
        guard !isCommitted else { return }
        isPressing = pressing
        if pressing {
            withAnimation(.linear(duration: holdDuration)) {
                progress = 1
            }
        } else {
            withAnimation(.snappy) {
                progress = 0
            }
        }
    }
}
