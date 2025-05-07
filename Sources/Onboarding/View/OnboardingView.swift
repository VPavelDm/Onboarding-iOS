//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI
import CoreUI

public struct OnboardingView<CustomStepView>: View where CustomStepView: View {
    @StateObject private var viewModel: OnboardingViewModel

    @State private var showError: Bool = false

    private let customStepView: (CustomStepParams) -> CustomStepView

    public init(
        configuration: OnboardingConfiguration,
        delegate: OnboardingDelegate,
        colorPalette: any ColorPalette,
        @ViewBuilder customStepView: @escaping (CustomStepParams) -> CustomStepView
    ) {
        self._viewModel = StateObject(wrappedValue: OnboardingViewModel(
            configuration: configuration,
            delegate: delegate,
            colorPalette: colorPalette
        ))
        self.customStepView = customStepView
    }

    public var body: some View {
        NavigationStackContent(step: viewModel.currentStep, customStepView: customStepView)
            .id(viewModel.currentStep)
            .transition(
                .asymmetric(
                    insertion: .opacity.animation(.easeInOut.delay(0.35)),
                    removal: .offset(y: 20).combined(with: .opacity).animation(.default)
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(viewModel.colorPalette.anyBackgroundView.ignoresSafeArea())
            .animation(.easeInOut, value: viewModel.currentStep)
            .onFirstAppear {
                do {
                    try await viewModel.loadSteps()
                } catch {
                    showError = true
                }
            }
            .environmentObject(viewModel)
    }
}

#Preview {
    MockOnboardingView()
}
