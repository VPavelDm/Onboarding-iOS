//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import SwiftUI
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Properties

    private let service: OnboardingService
    private let progressSubject = PassthroughSubject<Void, Never>()
    private let progressButtonSubject = PassthroughSubject<Void, Never>()
    private var cancellations = Set<AnyCancellable>()

    // MARK: - Outputs

    @Published var steps: [OnboardingStep] = []
    @Published var currentStep: OnboardingStep?
    @Published var userAnswers: [UserAnswer] = []

    let delegate: OnboardingDelegate
    let configuration: OnboardingConfiguration
    let colorPalette: any ColorPalette

    var finishProgress: AnyPublisher<Void, Never> {
        Publishers.CombineLatest(progressSubject, progressButtonSubject)
            .map { _ in Void() }
            .eraseToAnyPublisher()
    }

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
        currentStep = steps.first
    }

    func onAnswer(answers: [StepAnswer]) async {
        guard let currentStep else { return }

        let payloads = answers.compactMap(\.payload).map(UserAnswer.Payload.init(payload:))
        let answer = UserAnswer(
            onboardingStepID: currentStep.id,
            payloads: payloads
        )
        userAnswers.append(answer)
        await delegate.onAnswer(userAnswer: answer, allAnswers: userAnswers)

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if let nextStep = steps.first(where: { $0.id == answers.last?.nextStepID }) {
            self.currentStep = nextStep
        } else {
            let stepID = StepID("appHome")
            self.currentStep = OnboardingStep(id: stepID, type: .custom(stepID))
        }
    }

    func onProgressButton() {
        progressButtonSubject.send(Void())
    }

    func processAnswers(step: ProgressStep) async {
        finishProgress
            .asyncSink { [weak self] _ in
                await self?.onAnswer(answers: [step.answer])
            }
            .store(in: &cancellations)
        
        progressSubject.send(Void())
    }

    func format(string: String) -> String {
        delegate.format(string: string)
    }
}
