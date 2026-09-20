//
//  PlatformModifiers.swift
//  onboarding-ios
//

import SwiftUI

extension View {

    /// Reveals a bottom action button. It stays mounted and reveals through properties, so it keeps
    /// its height when hidden and the surrounding layout does not reflow.
    @ViewBuilder
    public func revealBottomButton(_ isVisible: Bool, animation: Animation = .easeOut(duration: 0.4)) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 16)
            .allowsHitTesting(isVisible)
            .animation(animation, value: isVisible)
    }

    @ViewBuilder
    public func bottomBar<Bar: View>(@ViewBuilder _ bar: () -> Bar) -> some View {
        self.safeAreaInset(edge: .bottom, content: bar)
    }

    /// Animates step-to-step changes; pairs with `onboardingStepTransition`.
    @ViewBuilder
    func onboardingStepAnimation(value: OnboardingStep?) -> some View {
        self.animation(.easeInOut, value: value)
    }

    @ViewBuilder
    func onboardingStepTransition() -> some View {
        self.transition(
            .asymmetric(
                insertion: .opacity
                    .animation(.easeInOut.delay(0.35)),
                removal: .offset(y: 20)
                    .combined(with: .opacity)
                    .animation(.default)
            )
        )
    }

    /// One item of a staggered "appear one by one" reveal. Pair with `staggeredReveal` on the
    /// container, which drives `revealed`.
    public func staggeredAppear(visible: Bool) -> some View {
        self
            .opacity(visible ? 1 : 0)
            .scaleEffect(visible ? 1 : 0.96)
            .offset(y: visible ? 0 : 8)
    }

    /// Drives the `revealed` counter for `staggeredAppear`, advancing it one step every
    /// `stagger` seconds after an `initialDelay` (defaults to letting the step's enter
    /// animation finish before the reveal starts).
    public func staggeredReveal(count: Int, revealed: Binding<Int>, initialDelay: Double = 0.35, stagger: Double = 0.06) -> some View {
        self.task {
            if initialDelay > 0 {
                try? await Task.sleep(for: .seconds(initialDelay))
            }
            for index in 0..<count {
                withAnimation(.easeOut(duration: 0.3)) {
                    revealed.wrappedValue = index + 1
                }
                try? await Task.sleep(for: .seconds(stagger))
            }
        }
    }

    /// Hold-to-confirm gesture.
    func holdToCommit(duration: Double, perform: @escaping () -> Void, onPressingChanged: @escaping (Bool) -> Void) -> some View {
        modifier(HoldToCommitModifier(duration: duration, perform: perform, onPressingChanged: onPressingChanged))
    }
}

struct HoldToCommitModifier: ViewModifier {
    let duration: Double
    let perform: () -> Void
    let onPressingChanged: (Bool) -> Void

    func body(content: Content) -> some View {
        content.onLongPressGesture(minimumDuration: duration, perform: perform, onPressingChanged: onPressingChanged)
    }
}
