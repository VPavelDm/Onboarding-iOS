//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import SwiftUI

@MainActor
@Observable
final class OnboardingViewModel {

    // MARK: - Properties

    private let service: OnboardingService

    // MARK: - Outputs

    var steps: [OnboardingStep] = []
    var currentStep: OnboardingStep?
    var userAnswers: [UserAnswer] = []

    /// Locale custom step views render in. Updated only alongside `currentStep`
    /// (see `show(_:)`), never reactively from the host's model, so a language
    /// the user picks mid-flow applies to the *next* step — the outgoing screen
    /// keeps its language until it's replaced (no in-place re-localise / flash).
    private(set) var displayLocale: Locale?

    let delegate: OnboardingDelegate
    let configuration: OnboardingConfiguration
    let colorPalette: any ColorPalette

    // MARK: - Inits

    init(configuration: OnboardingConfiguration, delegate: OnboardingDelegate, colorPalette: any ColorPalette) {
        self.configuration = configuration
        self.delegate = delegate
        self.service = OnboardingService(configuration: configuration)
        self.colorPalette = colorPalette
    }

    // MARK: - Intents

    func loadSteps() async throws {
        steps = try await service.fetchSteps()
            .filter(\.isNotUnknown)
            .map { attaching($0) ?? $0 }
        await advance(to: steps.first?.id)
    }

    /// Attach the completion callback to a custom step so it can advance.
    private func attaching(_ step: OnboardingStep?) -> OnboardingStep? {
        guard var step else { return nil }
        if case .custom(var params) = step.type {
            params.callback = onStepCompletion(answer:nextStepID:)
            step.type = .custom(params)
        }
        return step
    }

    func onAnswer(answers: [StepAnswer]) async {
        guard let currentStep else { return }

        let payloads = answers.compactMap(\.payload).map(UserAnswer.Payload.init(payload:))
        let answer = UserAnswer(
            onboardingStepID: currentStep.id,
            payloads: payloads
        )

        await onStepCompletion(answer: answer, nextStepID: answers.last?.nextStepID)
    }

    func format(string: String) -> String {
        delegate.format(string: string)
    }

    /// Localise a raw key from a step (or a fixed built-in key) for display.
    /// Called by step views at render time, so copy always reflects the app's
    /// current language.
    func localize(_ key: String) -> String {
        delegate.format(string: key)
    }

    // MARK: - Utils

    @Sendable
    private func onStepCompletion(answer: UserAnswer, nextStepID: StepID?) async {
        userAnswers.append(answer)
        await delegate.onAnswer(userAnswer: answer, allAnswers: userAnswers)

        playAdvanceFeedback()

        await advance(to: nextStepID)
    }

    // MARK: - Haptics
    //
    // One meaning per feel, so the flow never says the same thing two ways: a soft tap moves on,
    // the system selection tick marks a choice, a light tick marks work landing, a rigid knock is
    // a physical stamp, and success is kept for the moments the user earned.

    /// A soft tap when a step completes. Soft and below full strength: it fires on every screen,
    /// and a medium thud nineteen times over reads as noise.
    private func playAdvanceFeedback() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.7)
        #endif
    }

    /// The system selection tick, for choosing within a step: a tile, a chip, a stepper value.
    func playToggleFeedback() {
        #if canImport(UIKit)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }

    /// A light tick as a piece of work lands: a progress bar filling, a receipt line printing.
    func playTickFeedback(intensity: CGFloat = 0.6) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: intensity)
        #endif
    }

    /// A rigid knock for something that lands with weight, such as the receipt's stamp.
    func playStampFeedback() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        #endif
    }

    /// Success, for what the user earned: a finished plan, a commitment made.
    func playSuccessFeedback() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    private func advance(to startID: StepID?) async {
        var targetID = startID
        while let id = targetID, var step = steps.first(where: { $0.id == id }) {
            switch await delegate.routing(forStepID: id) {
            case .show:
                if case .custom(var params) = step.type {
                    params.callback = onStepCompletion(answer:nextStepID:)
                    step.type = .custom(params)
                }
                show(step)
                return
            case .skip(let branch):
                guard case .custom(let params) = step.type else {
                    // Only custom steps carry the branch/next metadata needed
                    // to resolve a skip target from here. Fall back to showing.
                    show(step)
                    return
                }
                targetID = branch.flatMap { params.branches[$0] } ?? params.nextStepID
            }
        }
    }

    /// Present a step and sample the host's preferred locale in the same
    /// synchronous transaction, so the locale change lands with the step change
    /// rather than one render early on the outgoing step.
    private func show(_ step: OnboardingStep) {
        currentStep = step
        displayLocale = delegate.preferredLanguageCode().map(Locale.init(identifier:))
    }
}
