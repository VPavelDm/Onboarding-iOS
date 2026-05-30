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
                insertion: .opacity.animation(.easeInOut.delay(0.35)),
                removal: .offset(y: 20).combined(with: .opacity).animation(.default)
            )
        )
        #endif
    }
}
