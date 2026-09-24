//
//  PaywallCTAButtonStyle.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI

/// The paywall's full-width accent CTA. Named for its role — the module already has
/// an unrelated internal `PrimaryButtonStyle`. Colors default to the accent fill
/// with primary label; hosts recolor it through `PaywallConfiguration`. Same
/// 54 pt slab as the onboarding steps' primary button, so a paywall inside a
/// flow does not shrink its CTA on the one screen that matters.
struct PaywallCTAButtonStyle: ButtonStyle {

    var background: Color?
    var foreground: Color?
    /// The host's own style from `paywallCTAButtonStyle(_:)`; wins when set.
    var custom: PaywallCustomCTAStyle?

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        if let custom {
            custom.makeBody(configuration: configuration)
        } else {
            slab(configuration)
        }
    }

    private func slab(_ configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(foreground ?? Color.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(background ?? Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
