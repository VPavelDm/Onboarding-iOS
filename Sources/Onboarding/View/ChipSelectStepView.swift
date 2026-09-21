//
//  File.swift
//  onboarding-ios
//

import SwiftUI
import CoreUI

struct ChipSelectStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State private var selected: [StepAnswer] = []
    @State private var appeared = false

    let step: ChipSelectStep

    private static let chipStagger: Double = 0.2
    private static let chipStartDelay: Double = 0.3

    private var canSubmit: Bool {
        selected.count >= step.minSelected
    }

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            header
            chips
            Spacer()
            continueButton
        }
        .padding(.horizontal, UIConstants.hScreenPadding)
        .padding(.bottom, UIConstants.vScreenPadding)
        .animation(.easeOut(duration: 0.3), value: canSubmit)
        .onAppear { appeared = true }
    }

    private var header: some View {
        VStack(spacing: UIConstants.headingSpacing) {
            titleView
            descriptionView
        }
    }

    private var titleView: some View {
        Text(viewModel.localize(step.title))
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(viewModel.localize(description))
                .font(.subheadline)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
    }

    private var chips: some View {
        FlowLayout(spacing: 10) {
            ForEach(Array(step.chips.enumerated()), id: \.element) { index, chip in
                ChipView(chip: chip, isSelected: selected.contains(chip)) {
                    toggle(chip)
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.7)
                .offset(y: appeared ? 0 : 12)
                .animation(
                    .spring(response: 0.32, dampingFraction: 0.75).delay(appearDelay(at: index)),
                    value: appeared
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var continueButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: step.answers(for: selected))
        } label: {
            Text(viewModel.localize(step.buttonTitle))
        }
        .buttonStyle(PrimaryButtonStyle(colorPalette: viewModel.colorPalette))
        .revealBottomButton(canSubmit)
    }

    private func appearDelay(at index: Int) -> Double {
        Self.chipStartDelay + Double(index) * Self.chipStagger
    }

    /// Selection keeps the order the chips were picked in, so the answer reads as the user built it.
    private func toggle(_ chip: StepAnswer) {
        viewModel.playToggleFeedback()
        if let index = selected.firstIndex(of: chip) {
            selected.remove(at: index)
        } else {
            selected.append(chip)
        }
    }
}

private struct ChipView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    let chip: StepAnswer
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                symbolView
                Text(viewModel.localize(chip.title))
            }
        }
        .buttonStyle(ChipButtonStyle(isSelected: isSelected))
    }

    /// An image wins when the chip carries one; otherwise the emoji, and otherwise nothing.
    @ViewBuilder
    private var symbolView: some View {
        if let image = chip.image {
            OnboardingImage(image: image, bundle: viewModel.configuration.bundle)
                .aspectRatio(contentMode: image.contentMode)
                .frame(height: 18)
        } else if let icon = chip.icon {
            Text(verbatim: icon)
        }
    }
}
