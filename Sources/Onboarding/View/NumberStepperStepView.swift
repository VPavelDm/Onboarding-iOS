import SwiftUI
import CoreUI

/// One number, picked with a stepper rather than typed, and the tiles under it doing the arithmetic
/// the user would otherwise do in their head before committing to it.
struct NumberStepperStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    let step: NumberStepperStep

    @State private var selectedIndex: Int

    init(step: NumberStepperStep) {
        self.step = step
        _selectedIndex = State(initialValue: step.defaultIndex)
    }

    private var selectedOption: Int {
        step.options.indices.contains(selectedIndex) ? step.options[selectedIndex] : 0
    }

    var body: some View {
        VStack(spacing: 28) {
            header
            VStack(spacing: 12) {
                stepperCard
                tiles
            }
            Spacer()
            continueButton
        }
        .padding(.top, .headerTopPadding)
        .padding(.horizontal, UIConstants.hScreenPadding)
        .padding(.bottom, UIConstants.vScreenPadding)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: UIConstants.headingSpacing) {
            Text(localized(step.title))
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(viewModel.colorPalette.textColor)
                .multilineTextAlignment(.center)
            if let description = step.description {
                Text(localized(description))
                    .font(.subheadline)
                    .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Stepper

    private var stepperCard: some View {
        VStack(spacing: 22) {
            stepperRow
            positionDots
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 26)
        .frame(maxWidth: .infinity)
        .glassBackground(cornerRadius: 28)
    }

    private var stepperRow: some View {
        HStack(spacing: 28) {
            stepperButton(systemName: "minus", enabled: selectedIndex > 0) {
                selectedIndex = max(selectedIndex - 1, 0)
            }
            Text(verbatim: "\(selectedOption)")
                .font(.system(size: 88, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(viewModel.colorPalette.textColor)
                .contentTransition(.numericText())
                .frame(minWidth: 120)
            stepperButton(systemName: "plus", enabled: selectedIndex < step.options.count - 1) {
                selectedIndex = min(selectedIndex + 1, step.options.count - 1)
            }
        }
    }

    private func stepperButton(systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.snappy) { action() }
            viewModel.playToggleFeedback()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(enabled ? 1 : 0.3))
                .frame(width: 48, height: 48)
                .background(viewModel.colorPalette.textColor.opacity(enabled ? 0.10 : 0.04))
                .clipShape(Circle())
                .overlay {
                    Circle().strokeBorder(viewModel.colorPalette.textColor.opacity(0.22), lineWidth: 1)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    /// Says how far along the options the choice sits, so the stepper reads as a short scale rather
    /// than an open-ended counter.
    private var positionDots: some View {
        HStack(spacing: 10) {
            ForEach(step.options.indices, id: \.self) { index in
                Capsule()
                    .fill(
                        index == selectedIndex
                            ? viewModel.colorPalette.accentColor
                            : viewModel.colorPalette.textColor.opacity(0.22)
                    )
                    .frame(width: index == selectedIndex ? 26 : 8, height: 6)
                    .animation(.snappy, value: selectedIndex)
            }
        }
    }

    // MARK: - Tiles

    private var tiles: some View {
        HStack(spacing: 12) {
            ForEach(Array(step.tiles.enumerated()), id: \.offset) { _, tile in
                tileView(tile)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func tileView(_ tile: NumberStepperStep.Tile) -> some View {
        VStack(spacing: 6) {
            Text(verbatim: "\(tile.value(forOption: selectedOption))")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(viewModel.colorPalette.textColor)
                .contentTransition(.numericText())
            Text(localized(tile.label))
                .font(.caption)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .multilineTextAlignment(.center)
                // One line at a fixed height, so tiles stay the same size in every language and
                // the card above them does not move as the number changes.
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(height: 20)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .padding(.vertical, 18)
        .glassBackground(cornerRadius: 18)
    }

    // MARK: - Button

    private var continueButton: some View {
        AsyncButton {
            await onContinue()
        } label: {
            Text(localized(step.answer.title))
        }
        .buttonStyle(PrimaryButtonStyle(colorPalette: viewModel.colorPalette))
    }

    private func onContinue() async {
        var answer = step.answer
        answer.payload = .string("\(selectedOption)")
        await viewModel.onAnswer(answers: [answer])
    }

    private func localized(_ key: String) -> String {
        viewModel.localize(key)
    }
}

private extension CGFloat {

    /// Clears the flow's own chrome without pushing the stepper off the middle of the screen.
    static let headerTopPadding: CGFloat = 80
}

// MARK: - Preview

#Preview {
    MockOnboardingView()
}
