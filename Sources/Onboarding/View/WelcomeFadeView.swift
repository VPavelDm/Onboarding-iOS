//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 30.03.25.
//

import SwiftUI
import CoreUI

struct EmptyButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct WelcomeFadeView<OuterScreen>: View where OuterScreen: View {
    @EnvironmentObject private var onboarding: OnboardingViewModel

    @State private var activeElementIndex: Int?
    @State private var displayFadeContent: Bool = true

    var step: WelcomeFadeStep
    let outerScreen: (OnboardingOuterScreenCallbackParams) -> OuterScreen

    var body: some View {
        VStack {
            if displayFadeContent {
                fadeContentView
            } else if onboarding.steps.count > 1 {
                NavigationStackContent(step: onboarding.steps[1], outerScreen: outerScreen)
            }
        }
        .onAppear {
            withAnimation(.easeInOut.delay(2)) {
                activeElementIndex = 0
            }
        }
    }

    private var fadeContentView: some View {
        AsyncButton {
            guard let activeElementIndex else { return }
            withAnimation {
                if activeElementIndex == step.messages.count - 1 {
                    displayFadeContent = false
                } else {
                    self.activeElementIndex = activeElementIndex + 1
                }
            }
        } label: {
            labelView
        }
        .buttonStyle(EmptyButtonStyle())
    }

    private var labelView: some View {
        VStack(alignment: .leading) {
            Spacer()
            Spacer()
            ForEach(step.messages.indices, id: \.self) { index in
                if activeElementIndex == index {
                    Text(step.messages[index])
                        .foregroundStyle(onboarding.colorPalette.textColor)
                        .font(.title)
                        .fontWeight(.semibold)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom),
                            removal: .move(edge: .top))
                            .combined(with: .opacity)
                        )
                }
            }
            Spacer()
            Spacer()
            Spacer()
            instructionView
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }

    private var instructionView: some View {
        Text("Tap to continue")
            .font(.footnote.bold())
            .frame(maxWidth: .infinity)
            .opacity(activeElementIndex != nil && activeElementIndex != step.messages.count ? 1 : 0)
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
