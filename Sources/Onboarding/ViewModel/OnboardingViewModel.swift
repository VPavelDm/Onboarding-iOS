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
        guard let maxStepsInChain = passedSteps.last?.maxStepsInChain else { return 1 }
        return min(CGFloat(passedSteps.count) / CGFloat(maxStepsInChain), 1)
    }

    let configuration: OnboardingConfiguration
    let completion: ([UserAnswer]) -> Void

    // MARK: - Inits

    init(configuration: OnboardingConfiguration, completion: @escaping ([UserAnswer]) -> Void) {
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

    func onAnswer(answers: [String] = []) {
        guard let currentStep else { return }
        userAnswers.append(UserAnswer(onboardingStepID: currentStep.id, answers: answers))
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if let nextStepIndex = steps.firstIndex(where: { $0.id == passedSteps.last?.nextStepID }) {
            passedSteps.append(steps[nextStepIndex])
            self.currentStep = passedSteps.last
        } else {
            completion(userAnswers)
        }
    }

    func onBack() {
        userAnswers.removeLast()
        passedSteps.removeLast()
        currentStep = passedSteps.last
    }
}
