//
//  PaywallRestoreButton.swift
//  onboarding-ios
//
//  Created by Claude on 30.09.26.
//

import SwiftUI

/// Restore as a corner pill on a hard paywall — the same quiet capsule as the
/// close button a dismissible paywall puts there, so the corner reads the same
/// either way.
struct PaywallRestoreButton: View {

    let textColor: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Restore", bundle: .module)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(textColor.opacity(0.7))
                .lineLimit(1)
                .padding(.horizontal, 12)
                .frame(minHeight: 30)
                .background(textColor.opacity(0.06), in: .capsule)
                .overlay(Capsule().stroke(textColor.opacity(0.08), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
