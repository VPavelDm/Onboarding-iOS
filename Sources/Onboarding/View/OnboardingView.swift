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
        contentView
            .progressView(isVisible: viewModel.currentStep == nil) {
                contentLoadingView
            }
            .background(viewModel.colorPalette.backgroundColor)
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
                NavigationStackContent(step: viewModel.steps.first, outerScreen: outerScreen)
                    .background(viewModel.colorPalette.backgroundColor)
                    .navigationDestination(
                        for: OnboardingStep.self,
                        destination: { step in
                            NavigationStackContent(
                                step: step,
                                outerScreen: outerScreen
                            )
                        }
                    )
                    .removeBackground()
            }
            .environmentObject(viewModel)
            if viewModel.shouldShowToolbar {
                customToolbarView
                    .frame(height: .progressBarHeight, alignment: .bottom)
            }
        }
    }

    private var customToolbarView: some View {
        HStack(spacing: 12) {
            backButton.opacity(viewModel.isBackButtonVisible ? 1 : 0)
            ProgressBarView(viewModel: viewModel)
                .opacity(viewModel.isProgressBarVisible ? 1 : 0)
            closeButton.opacity(viewModel.isCloseButtonVisible ? 1 : 0)
        }
        .padding(.horizontal, 12)
    }

    private var contentLoadingView: some View {
        ProgressView()
            .tint(viewModel.colorPalette.accentColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(viewModel.colorPalette.backgroundColor)
    }

    private var backButton: some View {
        AsyncButton {
            await viewModel.delegate.onBackButtonClick()
            viewModel.onBack()
        } label: {
            Image(systemName: "chevron.left")
                .tint(viewModel.colorPalette.plainButtonColor)
                .frame(width: 24, height: 24)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var closeButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [])
        } label: {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
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
