//
//  PaywallPlanTile.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI

/// A selectable plan card: cadence title, price, and a note — the trial length
/// when the plan has one, otherwise the billing cadence or the per-week price —
/// with an optional tag ("Popular", "Save 81%") on its top edge. The selection
/// ring slides between tiles via matched geometry and the selected tile takes a
/// wash of the accent.
struct PaywallPlanTile: View {

    let plan: PaywallPlan
    let isSelected: Bool
    let tag: PaywallPlanTag?
    var noteStyle: PaywallConfiguration.PlanNote = .billedCadence
    let selectionNamespace: Namespace.ID
    var textColor: Color = .white
    /// The host's accent for the ring, the wash and the tag; nil falls back to
    /// `Color.accentColor`, which resolves to the app's asset rather than its
    /// `.tint`, so a host whose asset is neutral got a grey ring (Lyncil, 2026-09-09).
    var accent: Color? = nil
    /// Text colour on the tag when `accent` is light (black on neon, say).
    var accentForeground: Color = .white
    let onSelect: () -> Void

    private let cornerRadius: CGFloat = 18
    private static let ringID = "paywall.selection.ring"

    private var tint: Color { accent ?? .accentColor }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                title
                price
                note
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 8)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .background {
            shape
                .fill(.ultraThinMaterial)
                .overlay(shape.fill(Color.black.opacity(0.22)))
                .overlay(shape.fill(Color.accentColor.opacity(0.10)))
                // The chosen tile reads in colour, not only by its ring: at a
                // glance two grey tiles with a 2 pt outline looked alike.
                .overlay(shape.fill(tint.opacity(isSelected ? 0.10 : 0)))
        }
        // 0.12 read as no edge at all on a dark page; the resting tile has one.
        .overlay(shape.strokeBorder(textColor.opacity(0.2), lineWidth: 1))
        .overlay {
            if isSelected {
                shape
                    .strokeBorder(tint, lineWidth: 2)
                    .matchedGeometryEffect(id: Self.ringID, in: selectionNamespace)
            }
        }
        .overlay(alignment: .top) { tagLabel }
        .animation(.easeOut(duration: 0.2), value: isSelected)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    private var title: some View {
        Text(plan.period.title)
            .font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .tracking(0.8)
            .foregroundStyle(isSelected ? tint : textColor.opacity(0.7))
    }

    /// Shrinks rather than wraps: three tiles leave a long local price ("1.299,00 ₽")
    /// under 100 pt.
    private var price: some View {
        Text(plan.localizedPrice)
            .font(.title2.weight(.bold))
            .monospacedDigit()
            .foregroundStyle(textColor)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    /// A trial is the one thing that sets two plans apart beyond the price, so
    /// the plan that has one says so here instead of only in the CTA. In the
    /// accent only while selected: lit on the resting tile it outshone the
    /// chosen one.
    @ViewBuilder
    private var note: some View {
        if let days = plan.freeTrialDays {
            Text("\(days)-day free trial", bundle: .module)
                .font(.footnote.weight(.medium))
                .foregroundStyle(isSelected ? tint : textColor.opacity(0.7))
        } else if noteStyle == .pricePerWeek, let perWeek = plan.localizedPricePerWeek {
            Text("\(perWeek)/week", bundle: .module)
                .font(.footnote)
                .monospacedDigit()
                .foregroundStyle(textColor.opacity(0.55))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        } else {
            Text(plan.period.billedCadence)
                .font(.footnote)
                .foregroundStyle(textColor.opacity(0.55))
        }
    }

    /// Rides the tile's top edge, centred. A saving reads "Save 87%" in the
    /// locale's own percent form: the locale-formatted "-87 %" it replaced read
    /// as a price drop, not a saving.
    @ViewBuilder
    private var tagLabel: some View {
        if let tag {
            tagText(tag)
                .font(.caption2.weight(.bold))
                .foregroundStyle(accentForeground)
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(tint, in: .capsule)
                .offset(y: -11)
        }
    }

    private func tagText(_ tag: PaywallPlanTag) -> Text {
        switch tag {
        case .popular:
            Text("Popular", bundle: .module)
        case .savings(let percent):
            Text("Save \((Double(percent) / 100).formatted(.percent.precision(.fractionLength(0))))", bundle: .module)
        }
    }
}
