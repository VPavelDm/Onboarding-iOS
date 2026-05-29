//
//  PlatformModifiers.swift
//  onboarding-ios
//
//  Thin wrappers around SwiftUI modifiers that Skip's SwiftUI (Android) doesn't implement.
//  They no-op on Android and forward to the real modifier on Apple platforms, so views can
//  use them unconditionally and the platform handling lives in one place.
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

    /// `.wheel` picker style is unavailable in Skip; fall back to `.menu` (a dropdown) on Android.
    @ViewBuilder
    func wheelPickerStyleCompat() -> some View {
        #if os(Android)
        self.pickerStyle(.menu)
        #else
        self.pickerStyle(.wheel)
        #endif
    }

    /// `contentShape` is unavailable in Skip; no-op there (gesture falls back to the view bounds).
    @ViewBuilder
    func contentShapeCompat<S: Shape>(_ shape: S) -> some View {
        #if os(Android)
        self
        #else
        self.contentShape(shape)
        #endif
    }

    /// Applied to a button's *label* so the Compose tap ripple covers the whole button.
    /// Skip puts the ripple on the label's bounds, so the label must fill the button.
    /// Android-only — on iOS the `ButtonStyle` already lays the label out.
    @ViewBuilder
    func applyRippleEffect(alignment: Alignment = .center) -> some View {
        #if os(Android)
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        #else
        self
        #endif
    }

    @ViewBuilder
    func bottomBar<Bar: View>(@ViewBuilder _ bar: () -> Bar) -> some View {
        #if os(Android)
        self.overlay(alignment: .bottom, content: bar)
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
                insertion: .opacity.animation(.easeInOut.delay(0.35)),
                removal: .offset(y: 20).combined(with: .opacity).animation(.default)
            )
        )
        #endif
    }
}
