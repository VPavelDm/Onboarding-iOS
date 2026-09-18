//
//  PaywallMark.swift
//  onboarding-ios
//
//  Created by Claude on 18.09.26.
//

import SwiftUI

/// The mark over the headline: the host's premium glyph in a haloed disc of
/// the CTA colour. Built for Lyncil's crown (2026-09-18), which the app had
/// been drawing over the paywall from outside as a top safe-area inset — that
/// pushed the whole column down and left the corner close mid-screen, so the
/// mark moved in here and became a configuration field (`headerSymbol`).
struct PaywallMark: View {
    let systemImage: String
    let tint: Color
    var size: CGFloat = 72

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(Circle().fill(tint.opacity(0.12)))
            .overlay(Circle().strokeBorder(tint.opacity(0.3), lineWidth: 1))
            .shadow(color: tint.opacity(0.25), radius: 16)
    }
}

/// A row icon on the feature list and the trial timeline: `.filled` is a solid
/// disc of the accent with the CTA's label colour on it, `.tinted` the same
/// translucent treatment as `PaywallMark`, so the mark, the rows and the plan
/// tiles read as one system and the CTA stays the only solid slab of accent.
struct PaywallIconDisc: View {
    let systemImage: String
    let tint: Color
    let foreground: Color
    let style: PaywallConfiguration.FeatureIconStyle
    var size: CGFloat = 28

    var body: some View {
        ZStack {
            switch style {
            case .filled:
                Circle().fill(tint)
            case .tinted:
                Circle()
                    .fill(tint.opacity(0.14))
                    .overlay(Circle().strokeBorder(tint.opacity(0.35), lineWidth: 1))
            }
            Image(systemName: systemImage)
                .font(.system(size: size * 0.43, weight: .bold))
                .foregroundStyle(style == .filled ? foreground : tint)
        }
        .frame(width: size, height: size)
    }
}
