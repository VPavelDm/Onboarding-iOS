//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 30.03.25.
//

import SwiftUI
import CoreUI

struct WelcomeFadeView<CustomStepView>: View where CustomStepView: View {
    @EnvironmentObject private var onboarding: OnboardingViewModel

    @State private var activeElementIndex: Int?

    var step: WelcomeFadeStep
    var customStepView: (CustomStepParams) -> CustomStepView

    var body: some View {
        VStack {
            if activeElementIndex.map({ $0 < step.messages.count }) ?? true {
                contentView
            } else if onboarding.steps.count > 1 {
                NavigationStackContent(
                    step: onboarding.steps[1],
                    customStepView: customStepView
                )
            }
        }
        .onAppear {
            displayNextText()
        }
    }

    private var contentView: some View {
        VStack {
            ForEach(step.messages.indices, id: \.self) { index in
                VStack {
                    if activeElementIndex == index {
                        messageView(step.messages[index])
                    }
                }
                .blur(radius: activeElementIndex == index ? 0 : 10)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func messageView(_ message: String) -> some View {
        Text(message)
            .foregroundStyle(onboarding.colorPalette.textColor)
            .font(.title)
            .apply { view in
                if #available(iOS 16.1, *) {
                    view.fontDesign(.rounded)
                }
            }
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .transition(.opacity)
    }

    func displayNextText() {
        guard activeElementIndex.map({ $0 < step.messages.count }) ?? true else { return }
        withAnimation(.default) {
            activeElementIndex = activeElementIndex.map { $0 + 1 } ?? 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            displayNextText()
        }
    }
}

#Preview {
    MockOnboardingView()
}
