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

    let delegate: OnboardingDelegate
    let configuration: OnboardingConfiguration
    let colorPalette: any ColorPalette
    let localizer: Localizer

    // MARK: - Inits

    init(configuration: OnboardingConfiguration, delegate: OnboardingDelegate, colorPalette: any ColorPalette) {
        self.configuration = configuration
        self.delegate = delegate
        self.service = OnboardingService(configuration: configuration)
        self.colorPalette = colorPalette
        self.localizer = Localizer(bundle: configuration.bundle, tableName: configuration.tableName)
    }

    // MARK: - Intents

    func loadSteps() async throws {
        var loaded = try await service.fetchSteps()
            .filter(\.isNotUnknown)
        for index in loaded.indices {
            if case .custom(var params) = loaded[index].type {
                params.callback = onStepCompletion(answer:nextStepID:)
                loaded[index].type = .custom(params)
            }
        }
        steps = loaded
        await advance(to: steps.first?.id)
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
                currentStep = step
                return
            case .skip(let branch):
                guard case .custom(let params) = step.type else {
                    // Only custom steps carry the branch/next metadata needed
                    // to resolve a skip target from here. Fall back to showing.
                    currentStep = step
                    return
                }
                targetID = branch.flatMap { params.branches[$0] } ?? params.nextStepID
            }
        }
    }
}
