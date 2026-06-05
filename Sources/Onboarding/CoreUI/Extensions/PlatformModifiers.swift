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

    /// Animates step-to-step changes on iOS (pairs with `onboardingStepTransition`); a no-op on
    /// Android, where it otherwise lets Skip apply an implicit fade to custom-step swaps.
    @ViewBuilder
    func onboardingStepAnimation(value: OnboardingStep?) -> some View {
        #if os(Android)
        self
        #else
        self.animation(.easeInOut, value: value)
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

    /// `staggeredAppear` on Android only — iOS shows the item immediately.
    @ViewBuilder
    public func androidStaggeredAppear(visible: Bool) -> some View {
        #if os(Android)
        staggeredAppear(visible: visible)
        #else
        self
        #endif
    }

    /// Like `androidStaggeredAppear` but opacity-only (no scale/offset) — use when the revealing
    /// view sits directly in a Spacer-centered stack, where Skip's animated scale/offset would
    /// reflow the layout and shift sibling views.
    @ViewBuilder
    public func androidStaggeredFade(visible: Bool) -> some View {
        #if os(Android)
        self.opacity(visible ? 1 : 0)
        #else
        self
        #endif
    }

    /// `staggeredReveal` on Android only — no-op on iOS.
    @ViewBuilder
    public func androidStaggeredReveal(count: Int, revealed: Binding<Int>, initialDelay: Double = 0.35, stagger: Double = 0.06) -> some View {
        #if os(Android)
        staggeredReveal(count: count, revealed: revealed, initialDelay: initialDelay, stagger: stagger)
        #else
        self
        #endif
    }

    /// Hold-to-confirm gesture. iOS uses `onLongPressGesture` as-is; Android drives the hold with a
    /// cancellable timer because Skip's `onLongPressGesture` is unusable for this: it ignores
    /// `minimumDuration` (fires at the ~0.5s system long-press timeout) and never reports release
    /// (its `onPressingChanged` only ever fires `true`). Android instead uses `DragGesture(minimumDistance: 0)`,
    /// whose `onChanged` fires on press-down (no touch-slop wait) and whose `onEnded` fires on release.
    func holdToCommit(duration: Double, perform: @escaping () -> Void, onPressingChanged: @escaping (Bool) -> Void) -> some View {
        modifier(HoldToCommitModifier(duration: duration, perform: perform, onPressingChanged: onPressingChanged))
    }
}

struct HoldToCommitModifier: ViewModifier {
    let duration: Double
    let perform: () -> Void
    let onPressingChanged: (Bool) -> Void

    @State var pressing = false
    @State var holdTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        #if os(Android)
        // DragGesture(minimumDistance: 0) fires onChanged on press-down (no slop wait) and onEnded
        // on release — onLongPressGesture reports neither correctly on Skip. begin() guards against
        // the repeated onChanged calls so the timer starts only once.
        content.gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in begin() }
                .onEnded { _ in cancel() }
        )
        #else
        content.onLongPressGesture(minimumDuration: duration, perform: perform, onPressingChanged: onPressingChanged)
        #endif
    }

    private func begin() {
        guard !pressing else { return }
        pressing = true
        onPressingChanged(true)
        holdTask = Task {
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            perform()
        }
    }

    private func cancel() {
        guard pressing else { return }
        pressing = false
        onPressingChanged(false)
        holdTask?.cancel()
        holdTask = nil
    }
}
