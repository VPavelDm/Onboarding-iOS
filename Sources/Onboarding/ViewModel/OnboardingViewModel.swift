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
    @Published var passedSteps: [OnboardingStep] = []
    @Published var currentStep: OnboardingStep?
    @Published var userAnswers: [UserAnswer] = []

    var passedStepsProcent: CGFloat {
        passedSteps.last?.passedPercent ?? 0.05
    }

    let delegate: OnboardingDelegate
    let configuration: OnboardingConfiguration
    let colorPalette: any ColorPalette

    var finishProgress: AnyPublisher<Void, Never> {
        Publishers.CombineLatest(progressSubject, progressButtonSubject)
            .map { _ in Void() }
            .eraseToAnyPublisher()
    }

    var isBackButtonVisible: Bool {
        guard passedSteps.count > 1 else { return false }
        return passedSteps.last?.isBackButtonVisible ?? true
    }

    var isProgressBarVisible: Bool {
        guard passedSteps.count > 1 else { return false }
        return passedSteps.last?.isProgressBarVisible ?? true
    }

    var isCloseButtonVisible: Bool {
        passedSteps.last?.isCloseButtonVisible ?? false
    }

    var shouldShowToolbar: Bool {
        steps.contains(where: { step in
            step.isCloseButtonVisible || step.isProgressBarVisible
        })
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
        guard let firstStep = steps.first else { throw OnboardingError.noSteps }
        passedSteps.append(firstStep)
        self.currentStep = firstStep
    }

    func onAnswer(answers: [StepAnswer]) async {
        guard let currentStep else { return }

        let payloads = answers.compactMap(\.payload).map(UserAnswer.Payload.init(payload:))
        let answer = UserAnswer(
            onboardingStepID: currentStep.id,
            title: currentStep.type.title,
            payloads: payloads
        )
        userAnswers.append(answer)
        await delegate.onAnswerClick(userAnswer: answer)

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if let nextStepIndex = steps.firstIndex(where: { $0.id == answers.last?.nextStepID }) {
            passedSteps.append(steps[nextStepIndex])
            self.currentStep = passedSteps.last
        } else {
            await delegate.finalise()
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
        
        try? await delegate.processAnswers(userAnswers)
        progressSubject.send(Void())
    }

    func onBack() {
        if !userAnswers.isEmpty {
            userAnswers.removeLast()
        }
        if !passedSteps.isEmpty {
            passedSteps.removeLast()
            currentStep = passedSteps.last
        }
    }

    func format(string: String) -> String {
        delegate.format(string: string)
    }
}
