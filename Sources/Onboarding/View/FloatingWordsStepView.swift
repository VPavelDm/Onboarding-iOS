//
//  FloatingWordsStepView.swift
//  onboarding-ios
//

import SwiftUI
import CoreUI

struct FloatingWordsStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var driftStarted = false
    @State private var pulse = false
    @State private var isDescriptionVisible = false
    @State private var isCaptionVisible = false
    @State private var isButtonVisible = false

    var step: FloatingWordsStep

    private struct WordPlacement {
        let startOffset: CGSize
        let endOffset: CGSize
        let size: CGFloat
        let opacity: Double
        let delay: Double
    }

    private let placements: [WordPlacement] = [
        WordPlacement(startOffset: .init(width: -90,  height: -40), endOffset: .init(width: -110, height: -260), size: 26, opacity: 0.50, delay: 0.0),
        WordPlacement(startOffset: .init(width: 80,   height: -60), endOffset: .init(width: 130,  height: -300), size: 22, opacity: 0.42, delay: 0.15),
        WordPlacement(startOffset: .init(width: -120, height: 30),  endOffset: .init(width: -200, height: -180), size: 30, opacity: 0.48, delay: 0.30),
        WordPlacement(startOffset: .init(width: 100,  height: 50),  endOffset: .init(width: 170,  height: -200), size: 20, opacity: 0.38, delay: 0.45),
        WordPlacement(startOffset: .init(width: -60,  height: 80),  endOffset: .init(width: -50,  height: -250), size: 24, opacity: 0.55, delay: 0.60),
        WordPlacement(startOffset: .init(width: 40,   height: -90), endOffset: .init(width: 90,   height: -320), size: 18, opacity: 0.32, delay: 0.75)
    ]

    var body: some View {
        VStack {
            floatingWordsView
                .padding(.horizontal, .hScreenPadding)
                .padding(.top, 48)
            VStack(spacing: .headingSpacing) {
                titleView
                descriptionView
                    .opacity(isDescriptionVisible ? 1 : 0)
                captionView
                    .opacity(isCaptionVisible ? 1 : 0)
            }
            .padding(.horizontal, .hScreenPadding)
            .frame(maxHeight: .infinity, alignment: .top)
            nextButton
                .padding(.horizontal, .hScreenPadding)
                .opacity(isButtonVisible ? 1 : 0)
        }
        .padding(.bottom, .vScreenPadding)
        .ignoresSafeArea(edges: .top)
        .task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            driftStarted = true
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
            withAnimation(.easeInOut.delay(2.0)) {
                isDescriptionVisible = true
                isCaptionVisible = true
            }
            withAnimation(.easeInOut.delay(2.4)) {
                isButtonVisible = true
            }
        }
    }

    // MARK: - Visual

    private var floatingWordsView: some View {
        ZStack {
            ForEach(Array(step.floatingWords.enumerated()), id: \.offset) { index, word in
                let placement = placements[index % placements.count]
                Text(word)
                    .font(.system(size: placement.size, design: .serif).italic().weight(.medium))
                    .foregroundStyle(
                        Color(red: 0.96, green: 0.93, blue: 0.85)
                            .opacity(driftStarted ? 0 : placement.opacity)
                    )
                    .offset(driftStarted ? placement.endOffset : placement.startOffset)
                    .blur(radius: driftStarted ? 5 : 1)
                    .animation(.easeIn(duration: 1.8).delay(placement.delay), value: driftStarted)
            }

            centralCard
        }
        .frame(height: 320)
    }

    private var centralCard: some View {
        VStack(spacing: 6) {
            Text(step.centralWord)
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .foregroundStyle(Color(red: 1.0, green: 0.88, blue: 0.20))
            if let translation = step.centralTranslation {
                Text(translation)
                    .font(.subheadline.italic())
                    .foregroundStyle(Color.white.opacity(0.78))
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        }
        .shadow(
            color: Color(red: 1.0, green: 0.88, blue: 0.20).opacity(pulse ? 0.45 : 0.2),
            radius: pulse ? 32 : 18
        )
        .scaleEffect(pulse ? 1.03 : 1.0)
    }

    // MARK: - Copy

    private var titleView: some View {
        Text(viewModel.delegate.format(string: localized("floatingWords.title")))
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var descriptionView: some View {
        let text = localized("floatingWords.description")
        if !text.isEmpty {
            Text(text)
                .font(.body.weight(.medium))
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.85))
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var captionView: some View {
        let text = localized("floatingWords.caption")
        if !text.isEmpty {
            Text(text)
                .font(.footnote.italic().weight(.medium))
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.75))
                .multilineTextAlignment(.center)
        }
    }

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [makeAnswer()])
        } label: {
            Text(localized("floatingWords.answerTitle"))
        }
        .buttonStyle(PrimaryButtonStyle(colorPalette: viewModel.colorPalette))
    }

    private func localized(_ key: String) -> String {
        viewModel.localizer.localize(key)
    }

    private func makeAnswer() -> StepAnswer {
        StepAnswer(
            title: localized("floatingWords.answerTitle"),
            icon: nil,
            nextStepID: step.nextStepID,
            payload: nil
        )
    }
}

#Preview {
    MockOnboardingView()
}
