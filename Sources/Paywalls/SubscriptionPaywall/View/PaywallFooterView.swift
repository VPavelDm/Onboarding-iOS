//
//  PaywallFooterView.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI

/// Restore · Redeem code · Terms · Privacy, separated by middots. Redeem code
/// appears only when the host offers it, Terms and Privacy only when it provides
/// their URLs.
struct PaywallFooterView: View {

    let termsURL: URL?
    let privacyURL: URL?
    var textColor: Color = .white
    var onRestore: () -> Void
    /// Nil leaves "Redeem code" out.
    var onRedeemCode: (() -> Void)?

    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(spacing: 0) {
            link(Text("Restore", bundle: .module), action: onRestore)
            if let onRedeemCode {
                separator
                link(Text("Redeem code", bundle: .module), action: onRedeemCode)
            }
            if let termsURL {
                separator
                link(Text("Terms", bundle: .module)) { openURL(termsURL) }
            }
            if let privacyURL {
                separator
                link(Text("Privacy", bundle: .module)) { openURL(privacyURL) }
            }
        }
        .font(.caption)
        .foregroundStyle(textColor.opacity(0.5))
    }

    private func link(_ text: Text, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            text
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var separator: some View {
        Text(verbatim: "·").foregroundStyle(textColor.opacity(0.3))
    }
}
