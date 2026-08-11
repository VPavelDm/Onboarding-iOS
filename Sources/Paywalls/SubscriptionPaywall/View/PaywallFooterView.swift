//
//  PaywallFooterView.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI

/// Restore · Terms · Privacy, separated by middots. Terms and Privacy only appear
/// when the host provides their URLs.
struct PaywallFooterView: View {

    let termsURL: URL?
    let privacyURL: URL?
    var onRestore: () -> Void

    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(spacing: 0) {
            link(Text("Restore", bundle: .module), action: onRestore)
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
        .foregroundStyle(.white.opacity(0.5))
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
        Text(verbatim: "·").foregroundStyle(.white.opacity(0.3))
    }
}
