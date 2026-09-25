//
//  PaywallCustomCTAStyle.swift
//  onboarding-ios
//
//  Created by Claude on 24.09.26.
//

import SwiftUI

/// A host's own button style for the paywall CTA, type-erased so it can travel
/// through the environment. Lets the paywall wear the host's design-system CTA
/// (a frosted slab, say) instead of the library's solid one. The style is installed
/// with `buttonStyle(_:)` rather than by calling its `makeBody`, so SwiftUI wires up
/// its `@Environment` properties (`isEnabled` and the like).
public struct PaywallCustomCTAStyle {
    private let install: (AnyView) -> AnyView

    public init<Style: ButtonStyle>(_ style: Style) {
        install = { AnyView($0.buttonStyle(style)) }
    }

    func apply(to button: some View) -> AnyView {
        install(AnyView(button))
    }
}

private struct PaywallCTAStyleKey: EnvironmentKey {
    static let defaultValue: PaywallCustomCTAStyle? = nil
}

extension EnvironmentValues {
    var paywallCTAStyle: PaywallCustomCTAStyle? {
        get { self[PaywallCTAStyleKey.self] }
        set { self[PaywallCTAStyleKey.self] = newValue }
    }
}

public extension View {
    /// Draws the paywall's CTA with `style`. `ctaBackground` then no longer paints
    /// the button; `ctaForeground` still tints its progress spinner.
    func paywallCTAButtonStyle<Style: ButtonStyle>(_ style: Style) -> some View {
        environment(\.paywallCTAStyle, PaywallCustomCTAStyle(style))
    }
}
