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

        playSelectionFeedback()

        await advance(to: nextStepID)
    }

    /// Medium haptic on step completion. No-op where UIKit is unavailable (e.g. Android).
    private func playSelectionFeedback() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }

    /// Light haptic for in-step interactions (e.g. toggling a multi-select option).
    /// Reusable from any step view. No-op where UIKit is unavailable (e.g. Android).
    func playToggleFeedback() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
