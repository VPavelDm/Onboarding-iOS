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
            if viewModel.steps.count > 1 {
                customToolbarView
                    .frame(height: .progressBarHeight, alignment: .bottom)
            }
        }
    }

    private var customToolbarView: some View {
        HStack(spacing: 12) {
            backButton.opacity(viewModel.isBackButtonVisible ? 1 : 0)
            ProgressBarView(completed: viewModel.passedStepsProcent)
            backButton.opacity(0)
        }
        .padding(.horizontal, 12)
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
            case .prime(let step):
                PrimeStepView(step: step)
            case .progress(let step):
                ProgressStepView(step: step)
            case .timePicker(let step):
                TimePickerStepView(step: step)
            case .discountWheel(let step):
                DiscountWheelStepView(step: step)
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

    private var backButton: some View {
        AsyncButton {
            await viewModel.delegate.onBackButtonClick()
            viewModel.passedSteps.removeLast()
        } label: {
            Image(systemName: "chevron.left")
                .tint(.primary)
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func handleOuterScreenCallback() async {
        switch viewModel.currentStep?.type {
        case .custom(let stepAnswer):
            await viewModel.onAnswer(answers: [stepAnswer])
        case .login(let stepAnswer):
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
    .preferredColorScheme(.dark)
}
