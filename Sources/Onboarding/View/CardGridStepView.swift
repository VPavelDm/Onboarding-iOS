//
//  File.swift
//  onboarding-ios
//

import SwiftUI
import CoreUI

struct CardGridStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State private var selected: StepAnswer?
    @State private var revealedCards = 0

    let step: CardGridStep

    private static let revealStartDelay: Duration = .milliseconds(350)
    private static let perCardStagger: Duration = .milliseconds(80)
    private static let revealDuration: Double = 0.3

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            header
            grid
            Spacer()
            if !step.autoNavigate {
                continueButton
            }
        }
        .padding(.horizontal, UIConstants.hScreenPadding)
        .padding(.bottom, UIConstants.vScreenPadding)
        .animation(.easeOut(duration: Self.revealDuration), value: selected)
        .task { await revealCards() }
    }

    /// Cards arrive one after another rather than all at once, so the choice reads as a list.
    private func revealCards() async {
        try? await Task.sleep(for: Self.revealStartDelay)
        for index in step.cards.indices {
            withAnimation(.easeOut(duration: Self.revealDuration)) {
                revealedCards = index + 1
            }
            try? await Task.sleep(for: Self.perCardStagger)
        }
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

    private var grid: some View {
        LazyVGrid(columns: gridColumns, spacing: UIConstants.buttonsSpacing) {
            ForEach(Array(step.cards.enumerated()), id: \.element) { index, card in
                CardGridTile(card: card, isSelected: selected == card) {
                    if step.autoNavigate {
                        await viewModel.onAnswer(answers: [step.answer(for: card)])
                    } else {
                        selected = card
                    }
                }
                .opacity(revealedCards > index ? 1 : 0)
                .scaleEffect(revealedCards > index ? 1 : 0.85)
            }
        }
    }

    private var gridColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: UIConstants.buttonsSpacing),
            count: step.columns
        )
    }

    private var continueButton: some View {
        AsyncButton {
            if let selected {
                await viewModel.onAnswer(answers: [step.answer(for: selected)])
            }
        } label: {
            Text(viewModel.localize(step.buttonTitle))
        }
        .buttonStyle(PrimaryButtonStyle(colorPalette: viewModel.colorPalette))
        .revealBottomButton(selected != nil)
    }
}

private struct CardGridTile: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    let card: StepAnswer
    let isSelected: Bool
    let onTap: () async -> Void

    var body: some View {
        AsyncButton {
            await onTap()
        } label: {
            VStack(spacing: 8) {
                symbolView
                titleView
            }
        } progress: {
            ProgressView()
                .tint(viewModel.colorPalette.primaryButtonForegroundColor)
        }
        .buttonStyle(CardGridTileButtonStyle(isSelected: isSelected))
    }

    /// An image wins when the card carries one; otherwise the emoji, and otherwise nothing.
    @ViewBuilder
    private var symbolView: some View {
        if let image = card.image {
            OnboardingImage(image: image, bundle: viewModel.configuration.bundle)
                .aspectRatio(contentMode: image.contentMode)
                .frame(height: 52)
        } else if let icon = card.icon {
            Text(verbatim: icon)
                .font(.system(size: 52))
        }
    }

    private var titleView: some View {
        Text(viewModel.localize(card.title))
            .font(.headline)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }
}
