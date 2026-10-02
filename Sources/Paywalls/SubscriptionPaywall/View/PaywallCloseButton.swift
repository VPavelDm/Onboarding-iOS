//
//  PaywallCloseButton.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI

/// The corner dismiss control on a dismissible paywall — quiet by design, drawn
/// entirely from the screen's text color.
struct PaywallCloseButton: View {

    let textColor: Color
    var style: PaywallConfiguration.CloseButtonStyle = .disc
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            switch style {
            case .disc:
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(textColor.opacity(0.5))
                    .frame(width: 30, height: 30)
                    .background(textColor.opacity(0.06), in: .circle)
                    .overlay(Circle().stroke(textColor.opacity(0.08), lineWidth: 1))
            case .glyph:
                // Same 30 pt footprint, so the corner padding is unchanged.
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(textColor.opacity(0.5))
                    .frame(width: 30, height: 30)
                    .contentShape(.rect)
            }
        }
        .buttonStyle(.plain)
    }
}
