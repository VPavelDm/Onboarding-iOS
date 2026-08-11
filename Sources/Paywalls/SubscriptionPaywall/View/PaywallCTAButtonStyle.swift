//
//  PaywallCTAButtonStyle.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI

/// The paywall's full-width accent CTA. Named for its role — the module already has
/// an unrelated internal `PrimaryButtonStyle`. Colors default to the accent fill
/// with primary label; hosts recolor it through `PaywallConfiguration`.
struct PaywallCTAButtonStyle: ButtonStyle {

    var background: Color?
    var foreground: Color?

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(foreground ?? Color.primary)
            .background(background ?? Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
