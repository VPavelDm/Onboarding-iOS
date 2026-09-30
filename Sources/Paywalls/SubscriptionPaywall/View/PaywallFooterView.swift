//
//  PaywallFooterView.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI

/// Restore · Redeem code · Terms · Privacy, separated by middots. Restore is
/// left out when the paywall puts it in the corner, Redeem code appears only
/// when the host offers it, Terms and Privacy only when it provides their URLs.
///
/// One row where it fits, else the store actions over the legal links. Four
/// links on one row ran out of room in Russian, French and Hindi, where the
/// last one broke mid-word ("Конфиденци-альность").
struct PaywallFooterView: View {

    let termsURL: URL?
    let privacyURL: URL?
    var textColor: Color = .white
    /// Nil leaves Restore out (the paywall shows it in the corner instead).
    var onRestore: (() -> Void)?
    /// Nil leaves "Redeem code" out.
    var onRedeemCode: (() -> Void)?

    @Environment(\.openURL) private var openURL

    var body: some View {
        ViewThatFits(in: .horizontal) {
            row(storeLinks + legalLinks)
            VStack(spacing: 0) {
                row(storeLinks)
                row(legalLinks)
            }
        }
        .font(.caption)
        .foregroundStyle(textColor.opacity(0.5))
    }

    private struct Link: Identifiable {
        let id: String
        let title: Text
        let action: () -> Void
    }

    private var storeLinks: [Link] {
        var links: [Link] = []
        if let onRestore {
            links.append(Link(id: "restore", title: Text("Restore", bundle: .module), action: onRestore))
        }
        if let onRedeemCode {
            links.append(Link(id: "redeem", title: Text("Redeem code", bundle: .module), action: onRedeemCode))
        }
        return links
    }

    private var legalLinks: [Link] {
        var links: [Link] = []
        if let termsURL {
            links.append(Link(id: "terms", title: Text("Terms", bundle: .module)) { openURL(termsURL) })
        }
        if let privacyURL {
            links.append(Link(id: "privacy", title: Text("Privacy", bundle: .module)) { openURL(privacyURL) })
        }
        return links
    }

    private func row(_ links: [Link]) -> some View {
        HStack(spacing: 0) {
            ForEach(links) { item in
                if item.id != links.first?.id {
                    separator
                }
                link(item)
            }
        }
    }

    private func link(_ item: Link) -> some View {
        Button(action: item.action) {
            item.title
                .lineLimit(1)
                .fixedSize()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var separator: some View {
        Text(verbatim: "·").foregroundStyle(textColor.opacity(0.3))
    }
}
