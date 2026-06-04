//
//  PlatformModifiers.swift
//  onboarding-ios
//

import SwiftUI

extension View {

    @ViewBuilder
    func fixedSizeCompat(horizontal: Bool, vertical: Bool) -> some View {
        #if os(Android)
        self
        #else
        self.fixedSize(horizontal: horizontal, vertical: vertical)
        #endif
    }

    @ViewBuilder
    func monospacedDigitCompat() -> some View {
        #if os(Android)
        self
        #else
        self.monospacedDigit()
        #endif
    }

    @ViewBuilder
    func numericContentTransitionCompat() -> some View {
        #if os(Android)
        self
        #else
        self.contentTransition(.numericText())
        #endif
    }

    @ViewBuilder
    func layoutPriorityCompat(_ value: Double) -> some View {
        #if os(Android)
        self
        #else
        self.layoutPriority(value)
        #endif
    }

    @ViewBuilder
    func wheelPickerStyleCompat() -> some View {
        #if os(Android)
        self.pickerStyle(.menu)
        #else
        self.pickerStyle(.wheel)
        #endif
    }

    @ViewBuilder
    func contentShapeCompat<S: Shape>(_ shape: S) -> some View {
        #if os(Android)
        self
        #else
        self.contentShape(shape)
        #endif
    }

    @ViewBuilder
    public func applyRippleEffect(alignment: Alignment = .center) -> some View {
        #if os(Android)
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        #else
        self
        #endif
    }

    /// Reveal for a bottom action button in a Spacer-balanced layout (the button is inline at the
    /// bottom of the content, e.g. ComparisonCards). Stays mounted and reveals via properties —
    /// it keeps its height when hidden, which the surrounding Spacers absorb without reflow.
    /// - Android: opacity fade.
    /// - iOS: opacity fade + slight slide-up.
    @ViewBuilder
    public func revealBottomButton(_ isVisible: Bool, animation: Animation = .easeOut(duration: 0.4)) -> some View {
        #if os(Android)
        self
            .opacity(isVisible ? 1 : 0)
            .allowsHitTesting(isVisible)
            .animation(animation, value: isVisible)
        #else
        self
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 16)
            .allowsHitTesting(isVisible)
            .animation(animation, value: isVisible)
        #endif
    }

    /// Reveal for a bottom action button pinned in a `.bottomBar` over a scroll view (e.g.
    /// OneAnswer, Exercises). Fades the button in/out so it reserves no space at the bottom when hidden.
    /// - Android: opacity fade + collapses to zero height (the bottomBar is a plain VStack, so the
    ///   button must reserve no space itself).
    /// - iOS: opacity fade + slight slide-up; `safeAreaInset` manages the reserved space, so no
    ///   height collapse is needed.
    @ViewBuilder
    public func revealBottomBarButton(_ isVisible: Bool, animation: Animation = .easeOut(duration: 0.4)) -> some View {
        #if os(Android)
        self
            .opacity(isVisible ? 1 : 0)
            .frame(height: isVisible ? nil : 0)
            .clipped()
            .allowsHitTesting(isVisible)
            .animation(animation, value: isVisible)
        #else
        self
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 16)
            .allowsHitTesting(isVisible)
            .animation(animation, value: isVisible)
        #endif
    }

    @ViewBuilder
    public func bottomBar<Bar: View>(@ViewBuilder _ bar: () -> Bar) -> some View {
        #if os(Android)
        VStack(spacing: 0) {
            self
            bar()
        }
        #else
        self.safeAreaInset(edge: .bottom, content: bar)
        #endif
    }

    @ViewBuilder
    func scrollDismissesKeyboardCompat() -> some View {
        #if os(Android)
        self
        #else
        self.scrollDismissesKeyboard(.interactively)
        #endif
    }

    @ViewBuilder
    func onboardingStepTransition() -> some View {
        #if os(Android)
        self
        #else
        self.transition(
            .asymmetric(
                insertion: .opacity
                    .animation(.easeInOut.delay(0.35)),
                removal: .offset(y: 20)
                    .combined(with: .opacity)
                    .animation(.default)
            )
        )
        #endif
    }
}
