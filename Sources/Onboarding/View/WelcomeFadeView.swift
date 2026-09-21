//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 30.03.25.
//

import SwiftUI
import CoreUI

struct WelcomeFadeView: View {
    @Environment(OnboardingViewModel.self) var onboarding: OnboardingViewModel

    @State var activeElementIndex: Int?

    var step: WelcomeFadeStep

    /// How long each message holds the screen before the next one replaces it.
    private static let messageDuration: Duration = .seconds(3)

    var body: some View {
        contentView
            .task {
                do {
                    try await Task.sleep(for: .seconds(step.delay))
                    for index in step.messages.indices {
                        withAnimation(.default) { activeElementIndex = index }
                        try await Task.sleep(for: Self.messageDuration)
                    }
                } catch {
                    // Cancelled because the view went away — leave the flow where it is.
                    return
                }
                await onboarding.onAnswer(answers: [
                    StepAnswer(title: "", icon: nil, nextStepID: resolvedNextStepID, payload: nil)
                ])
            }
    }

    /// The step may name its successor; otherwise the flow continues with whatever follows it in
    /// the steps file.
    private var resolvedNextStepID: StepID? {
        if let declared = step.nextStepID {
            return declared
        }
        guard let currentID = onboarding.currentStep?.id,
              let index = onboarding.steps.firstIndex(where: { $0.id == currentID }),
              onboarding.steps.indices.contains(index + 1)
        else {
            return nil
        }
        return onboarding.steps[index + 1].id
    }

    private var contentView: some View {
        VStack {
            ForEach(step.messages.indices, id: \.self) { index in
                VStack {
                    if activeElementIndex == index {
                        messageView(onboarding.localize(step.messages[index]))
                    }
                }
                .blur(radius: activeElementIndex == index ? 0 : 10)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func messageView(_ message: String) -> some View {
        messageText(message)
            .foregroundStyle(onboarding.colorPalette.textColor)
            .font(.title)
            .apply { view in
                if #available(iOS 16.1, *) {
                    view.fontDesign(.rounded)
                }
            }
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .transition(.opacity)
    }

    private func messageText(_ message: String) -> Text {
        return Text(attributedMessage(message))
    }

    private func attributedMessage(_ message: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        guard var attributed = try? AttributedString(markdown: message, options: options) else {
            return AttributedString(message)
        }
        for run in attributed.runs where run.inlinePresentationIntent?.contains(.stronglyEmphasized) == true {
            attributed[run.range].foregroundColor = onboarding.colorPalette.accentColor
        }
        return attributed
    }
}

#Preview {
    MockOnboardingView()
}
