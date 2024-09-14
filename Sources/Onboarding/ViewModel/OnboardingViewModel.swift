//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Properties

    private let service: OnboardingService

    // MARK: - Outputs

    @Published var steps: [OnboardingStep] = []
    @Published var passedSteps: [OnboardingStep] = []
    @Published var currentStep: OnboardingStep?
    @Published var userAnswers: [UserAnswer] = []

    var passedStepsProcent: CGFloat {
        passedSteps.last?.passedPercent ?? 0.05
    }

    var showBackButton: Bool {
        !userAnswers.isEmpty
    }

    let configuration: OnboardingConfiguration
    let completion: ([UserAnswer]) async -> Void

    // MARK: - Inits

    init(configuration: OnboardingConfiguration, completion: @escaping ([UserAnswer]) async -> Void) {
        self.configuration = configuration
        self.service = OnboardingService(configuration: configuration)
        self.completion = completion
    }

    // MARK: - Intents

    func loadSteps() async throws {
        steps = try await service.fetchSteps()
            .filter(\.isNotUnknown)
        guard let firstStep = steps.first else { throw OnboardingError.noSteps }
        passedSteps.append(firstStep)
        self.currentStep = firstStep
    }

    func onAnswer(answers: [StepAnswer]) async {
        guard let currentStep else { return }
        userAnswers.append(UserAnswer(
            onboardingStepID: currentStep.id,
            payloads: answers.compactMap(\.payload).map(UserAnswer.Payload.init(payload:))
        ))
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if let nextStepIndex = steps.firstIndex(where: { $0.id == answers.last?.nextStepID }) {
            passedSteps.append(steps[nextStepIndex])
            self.currentStep = passedSteps.last
        } else {
            await completion(userAnswers)
        }
    }

    func onBack() {
        userAnswers.removeLast()
        passedSteps.removeLast()
        currentStep = passedSteps.last
    }
}
