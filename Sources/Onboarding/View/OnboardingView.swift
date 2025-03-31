//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI
import CoreUI

public struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel

    @State private var showError: Bool = false

    public init(
        configuration: OnboardingConfiguration,
        delegate: OnboardingDelegate,
        colorPalette: any ColorPalette
    ) {
        self._viewModel = StateObject(wrappedValue: OnboardingViewModel(
            configuration: configuration,
            delegate: delegate,
            colorPalette: colorPalette
        ))
    }

    public var body: some View {
        NavigationStack(path: $viewModel.passedSteps) {
            NavigationStackContent(step: viewModel.steps.first)
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
                        NavigationStackContent(step: step)
                    }
                )
        }
        .environmentObject(viewModel)
    }

    private var contentLoadingView: some View {
        ProgressView()
            .tint(viewModel.colorPalette.accentColor)
    }
}

#Preview {
    OnboardingView(
        configuration: .testData(),
        delegate: MockOnboardingDelegate(),
        colorPalette: .testData
    )
    .preferredColorScheme(.dark)
}
