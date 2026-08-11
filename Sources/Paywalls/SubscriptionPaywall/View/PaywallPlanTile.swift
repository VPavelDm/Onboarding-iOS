//
//  PaywallPlanTile.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI

/// A selectable plan card: cadence title, price, billing subtitle, and an optional
/// savings badge. The selection ring slides between tiles via matched geometry.
struct PaywallPlanTile: View {

    let plan: PaywallPlan
    let isSelected: Bool
    let savingsBadge: String?
    let selectionNamespace: Namespace.ID
    var textColor: Color = .white
    let onSelect: () -> Void

    private let cornerRadius: CGFloat = 16
    private static let ringID = "paywall.selection.ring"

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                title
                price
                subtitle
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .background {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.black.opacity(0.22)))
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.accentColor.opacity(0.10)))
        }
        .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(textColor.opacity(0.12), lineWidth: 1))
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.accentColor, lineWidth: 2)
                    .matchedGeometryEffect(id: Self.ringID, in: selectionNamespace)
            }
        }
        .overlay(alignment: .topTrailing) {
            if let savingsBadge {
                Text(savingsBadge)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.accentColor, in: .capsule)
                    .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
                    .offset(x: -10, y: -10)
            }
        }
    }

    private var title: some View {
        Text(plan.period.title)
            .font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .tracking(0.8)
            .foregroundStyle(textColor.opacity(0.7))
    }

    private var price: some View {
        Text(plan.localizedPrice)
            .font(.title2.weight(.bold))
            .monospacedDigit()
            .foregroundStyle(textColor)
            .padding(.top, 2)
    }

    private var subtitle: some View {
        Text(plan.period.billedCadence)
            .font(.footnote)
            .foregroundStyle(textColor.opacity(0.55))
    }
}
