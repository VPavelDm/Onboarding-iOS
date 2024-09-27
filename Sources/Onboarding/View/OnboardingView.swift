//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI
import CoreUI

public struct OnboardingView<OuterScreen>: View where OuterScreen: View {
    @StateObject private var viewModel: OnboardingViewModel

    @State private var showError: Bool = false

    let colorPalette: ColorPalette
    let outerScreen: (OnboardingOuterScreenCallbackParams) -> OuterScreen

    public init(
        configuration: OnboardingConfiguration,
        delegate: OnboardingDelegate,
        @ViewBuilder outerScreen: @escaping (OnboardingOuterScreenCallbackParams) -> OuterScreen
    ) {
        self._viewModel = StateObject(wrappedValue: OnboardingViewModel(
            configuration: configuration,
            delegate: delegate
        ))
        self.colorPalette = configuration.colorPalette
        self.outerScreen = outerScreen
    }

    public var body: some View {
        contentView
            .progressView(isVisible: viewModel.currentStep == nil) {
                contentLoadingView
            }
            .environment(\.colorPalette, colorPalette)
            .background(colorPalette.backgroundColor)
            .onFirstAppear {
                do {
                    try await viewModel.loadSteps()
                } catch {
                    showError = true
                }
            }
    }

    @ViewBuilder
    private var contentView: some View {
        ZStack(alignment: .top) {
            NavigationStack(path: $viewModel.passedSteps) {
                navigationStackContentView(step: viewModel.steps.first)
                    .navigationDestination(for: OnboardingStep.self, destination: navigationStackContentView(step:))
            }
            .environmentObject(viewModel)
            customToolbarView
                .frame(height: .progressBarHeight, alignment: .bottom)
        }
    }

    private var customToolbarView: some View {
        ProgressBarView(completed: viewModel.passedStepsProcent)
            .padding(.horizontal, 32)
    }

    private func navigationStackContentView(step: OnboardingStep?) -> some View {
        VStack(spacing: 0) {
            switch step?.type {
            case .welcome(let welcomeStep):
                WelcomeView(step: welcomeStep)
            case .oneAnswer(let oneAnswerStep):
                OneAnswerView(step: oneAnswerStep)
            case .binaryAnswer(let binaryAnswerStep):
                BinaryAnswerView(step: binaryAnswerStep)
            case .multipleAnswer(let multipleAnswerStep):
                MultipleAnswerView(step: multipleAnswerStep)
            case .description(let descriptionStep):
                DescriptionStepView(step: descriptionStep)
            case .login:
                outerScreen((.login, handleOuterScreenCallback))
            case .custom:
                if let stepID = step?.id {
                    outerScreen((.custom(stepID), handleOuterScreenCallback))
                }
            case .prime:
                outerScreen((.prime, handleOuterScreenCallback))
            case .progress(let step):
                ProgressStepView(step: step)
            case .timePicker(let step):
                TimePickerStepView(step: step)
            case .casino(let step):
                CasinoStepView()
            case .unknown, .none:
                EmptyView()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var contentLoadingView: some View {
        ProgressView()
            .tint(colorPalette.primaryButtonBackgroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorPalette.backgroundColor)
    }

    private func handleOuterScreenCallback() async {
        switch viewModel.currentStep?.type {
        case .custom(let stepAnswer):
            await viewModel.onAnswer(answers: [stepAnswer])
        case .login(let stepAnswer):
            await viewModel.onAnswer(answers: [stepAnswer])
        case .prime(let stepAnswer):
            await viewModel.onAnswer(answers: [stepAnswer])
        default:
            break
        }
    }
}

#Preview {
    OnboardingView(
        configuration: .testData(),
        delegate: MockOnboardingDelegate(),
        outerScreen: { type, completion in
            Button {
            } label: {
                Text("Next")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ColorPalette.testData.backgroundColor)
        }
    )
}
