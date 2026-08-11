//
//  PaywallPriceCard.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI

/// The single-plan alternative to the tile selector: product name and a one-line
/// note on the left, the price on the right. Shown when the offering resolves to
/// exactly one plan — typically a lifetime unlock.
struct PaywallPriceCard: View {

    /// Nil while offerings load — the card renders redacted placeholders so the
    /// layout doesn't jump when the real plan lands.
    let plan: PaywallPlan?
    /// Host copy for the note line; nil falls back to the plan's own wording.
    let note: String?
    let textColor: Color
    /// Solid card fill, or nil for the same material treatment as the plan tiles.
    let background: Color?

    private let cornerRadius: CGFloat = 20

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(textColor)
                Text(noteText)
                    .font(.footnote)
                    .foregroundStyle(textColor.opacity(0.55))
            }
            .redacted(reason: plan == nil ? .placeholder : [])
            Spacer(minLength: 0)
            Text(plan?.localizedPrice ?? "—")
                .font(.title.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(textColor)
                .redacted(reason: plan == nil ? .placeholder : [])
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(textColor.opacity(0.1), lineWidth: 1)
        }
    }

    private var title: String {
        guard let plan else { return "————————" }
        return plan.localizedTitle ?? plan.period.title
    }

    private var noteText: String {
        guard let plan else { return "————————————" }
        return note ?? defaultNote(for: plan)
    }

    private func defaultNote(for plan: PaywallPlan) -> String {
        switch plan.period {
        case .lifetime: String(localized: "One payment. No subscription, ever.", bundle: .module)
        case .weekly, .monthly, .yearly: plan.period.billedCadence
        }
    }

    @ViewBuilder
    private var cardBackground: some View {
        if let background {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(background)
                .shadow(color: textColor.opacity(0.06), radius: 8, y: 4)
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.black.opacity(0.22)))
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.accentColor.opacity(0.10)))
        }
    }
}
