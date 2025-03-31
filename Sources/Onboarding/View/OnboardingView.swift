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

    let outerScreen: (OnboardingOuterScreenCallbackParams) -> OuterScreen

    public init(
        configuration: OnboardingConfiguration,
        delegate: OnboardingDelegate,
        colorPalette: any ColorPalette,
        @ViewBuilder outerScreen: @escaping (OnboardingOuterScreenCallbackParams) -> OuterScreen
    ) {
        self._viewModel = StateObject(wrappedValue: OnboardingViewModel(
            configuration: configuration,
            delegate: delegate,
            colorPalette: colorPalette
        ))
        self.outerScreen = outerScreen
    }

    public var body: some View {
        NavigationStack(path: $viewModel.passedSteps) {
            NavigationStackContent(step: viewModel.steps.first, outerScreen: outerScreen)
                .progressView(isVisible: viewModel.currentStep == nil) {
                    contentLoadingView
                }
                .onFirstAppear {
                    do {
                        try await viewModel.loadSteps()
                    } catch {
                        showError = true
                    }
                }
                .navigationDestination(
                    for: OnboardingStep.self,
                    destination: { step in
                        NavigationStackContent(
                            step: step,
                            outerScreen: outerScreen
                        )
                    }
                )
                .navigationBarBackButtonHidden(viewModel.currentStep?.isBackButtonVisible == false)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        ProgressBarView(viewModel: viewModel)
                            .opacity(viewModel.isProgressBarVisible ? 1 : 0)
                    }
                }
        }
        .environmentObject(viewModel)
    }

    private var contentLoadingView: some View {
        ProgressView()
            .tint(viewModel.colorPalette.accentColor)
    }
}

#Preview {
    if #available(iOS 18.0, *) {
        OnboardingView(
            configuration: .testData(),
            delegate: MockOnboardingDelegate(),
            colorPalette: .testData,
            outerScreen: { _ in
            }
        )
        .preferredColorScheme(.dark)
        .background(AffirmationBackgroundView())
    }
}
