//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI
import CoreUI

public struct OnboardingView<CustomStepView>: View where CustomStepView: View {
    @Environment(\.locale) var ambientLocale
    @State var viewModel: OnboardingViewModel

    @State var showError: Bool = false

    private let customStepView: (CustomStepParams) -> CustomStepView

    public init(
        configuration: OnboardingConfiguration,
        delegate: OnboardingDelegate,
        colorPalette: any ColorPalette,
        @ViewBuilder customStepView: @escaping (CustomStepParams) -> CustomStepView
    ) {
        self._viewModel = State(wrappedValue: OnboardingViewModel(
            configuration: configuration,
            delegate: delegate,
            colorPalette: colorPalette
        ))
        self.customStepView = customStepView
    }

    public var body: some View {
        NavigationStackContent(step: viewModel.currentStep, customStepView: customStepView)
            // Drive the custom-step locale from the flow, not the ambient
            // environment. `displayLocale` only changes alongside the step, and
            // OnboardingView never reads the host's model, so picking a language
            // localises the *next* step. Applied *inside* `.id` so the locale is
            // baked into each step's identity: the outgoing step keeps its own
            // language while it transitions out instead of being re-localised in
            // place by a shared parent environment.
            .environment(\.locale, viewModel.displayLocale ?? ambientLocale)
            .id(viewModel.currentStep)
            .onboardingStepTransition()
            .progressView(isVisible: viewModel.currentStep == nil) {
                contentLoadingView
            }
            .onboardingStepAnimation(value: viewModel.currentStep)
            .onFirstAppear {
                do {
                    try await viewModel.loadSteps()
                } catch {
                    showError = true
                }
            }
            .environment(viewModel)
    }

    private var contentLoadingView: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if !os(Android)
#Preview {
    MockOnboardingView()
}
#endif
