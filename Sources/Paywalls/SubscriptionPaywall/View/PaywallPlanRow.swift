//
//  PaywallPlanRow.swift
//  onboarding-ios
//
//  Created by Claude on 02.10.26.
//

import SwiftUI

/// A selectable plan as a full-width row, for `PaywallConfiguration.planLayout
/// = .rows`: the plan's name ("Yearly Access") over what it costs in all
/// ("$59.99", and the trial if it has one) on the left, and on the right what
/// that comes to per week ("$1.15/week"), so plans of different lengths compare
/// in one unit. No radio: the chosen row shows by its ring and wash, as a tile
/// does. The tag rides the top edge near the trailing corner.
struct PaywallPlanRow: View {

    let plan: PaywallPlan
    let isSelected: Bool
    let tag: PaywallPlanTag?
    /// Struck through before the price; nil shows the price alone.
    var regularPrice: String? = nil
    var noteStyle: PaywallConfiguration.PlanNote = .billedCadence
    let selectionNamespace: Namespace.ID
    var textColor: Color = .white
    var accent: Color? = nil
    var accentForeground: Color = .white
    var savingsBackground: Color? = nil
    var savingsForeground: Color? = nil
    var popularBackground: Color? = nil
    var popularForeground: Color? = nil
    /// The host's word for the featured plan; nil says "Popular".
    var popularTitle: String? = nil
    var selection: PaywallConfiguration.PlanSelection = .ring
    /// The tallest row's height, so every row matches the one whose text runs
    /// tallest (a larger Dynamic Type size, a long local price); its content
    /// stays centred.
    var matchedHeight: CGFloat = 0
    /// The row's own height before matching, for the list to find the tallest.
    var onNaturalHeight: (CGFloat) -> Void = { _ in }
    let onSelect: () -> Void

    private let cornerRadius: CGFloat = 18
    private static let ringID = "paywall.selection.ring"

    private var tint: Color { accent ?? .accentColor }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(plan.period.accessTitle)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(textColor)
                    total
                }
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                Spacer(minLength: 8)
                comparison
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(minHeight: 68)
            .onGeometryChange(for: CGFloat.self, of: \.size.height) { onNaturalHeight($0) }
            .frame(minHeight: matchedHeight)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .background {
            shape
                .fill(.ultraThinMaterial)
                .overlay(shape.fill(Color.black.opacity(0.22)))
                .overlay(shape.fill(Color.accentColor.opacity(0.10)))
                .overlay(shape.fill(tint.opacity(isSelected ? selectedWash : 0)))
        }
        .overlay(shape.strokeBorder(textColor.opacity(0.2), lineWidth: 1))
        .overlay {
            if isSelected {
                shape
                    .strokeBorder(tint, lineWidth: 2)
                    .matchedGeometryEffect(id: Self.ringID, in: selectionNamespace)
            }
        }
        .overlay(alignment: .topTrailing) { tagLabel }
        .animation(.easeOut(duration: 0.2), value: isSelected)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var selectedWash: Double { selection == .filled ? 0.32 : 0.10 }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    /// The whole price, after the regular one struck through when there is
    /// one, and the trial after it when the plan has one: in the accent while
    /// chosen under `.ring`, as on the tile. A weekly plan's price is already
    /// the per-week figure on the right, so it isn't said twice (Pavel,
    /// 2026-10-02); with no trial either, the line goes and the title centres.
    @ViewBuilder
    private var total: some View {
        let showsPrice = !repeatsComparison || regularPrice != nil
        if showsPrice || plan.freeTrialDays != nil {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                if showsPrice {
                    if let regularPrice {
                        Text(regularPrice)
                            .font(.subheadline)
                            .strikethrough()
                            .monospacedDigit()
                            .foregroundStyle(textColor.opacity(0.45))
                    }
                    billedAmount(plan.localizedPrice)
                }
                if let days = plan.freeTrialDays {
                    if showsPrice {
                        Text(verbatim: "·")
                            .font(.subheadline)
                            .foregroundStyle(textColor.opacity(0.4))
                    }
                    Text("\(days)-day free trial", bundle: .module)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(isSelected && selection == .ring ? tint : textColor.opacity(0.7))
                }
            }
        }
    }

    /// What the store charges, the most prominent price on the row: App
    /// Review rejects a calculated price (per week, struck through, a trial)
    /// that stands out more than the billed amount (Guideline 3.1.2).
    private func billedAmount(_ text: String) -> some View {
        Text(text)
            .font(.title3.weight(.bold))
            .monospacedDigit()
            .foregroundStyle(textColor)
    }

    /// The right side already reads "$5.99/week" for a weekly plan.
    private var repeatsComparison: Bool {
        noteStyle == .pricePerWeek && plan.period == .weekly && plan.localizedPricePerWeek != nil
    }

    /// The price per week with `planNote: .pricePerWeek`; otherwise, or for a
    /// plan with no cadence (lifetime), how it is billed. One style on every
    /// row, so the weekly plan's price lines up with the yearly one's
    /// comparison (Pavel, 2026-10-02); on that row it is the only price.
    private var comparison: some View {
        Group {
            if noteStyle == .pricePerWeek, let perWeek = plan.localizedPricePerWeek {
                Text("\(perWeek)/week", bundle: .module)
                    .monospacedDigit()
            } else {
                Text(plan.period.billedCadence)
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(textColor)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }

    @ViewBuilder
    private var tagLabel: some View {
        if let tag {
            tagText(tag)
                .font(.caption2.weight(.bold))
                .foregroundStyle(tagColors(tag).foreground)
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(tagColors(tag).background, in: .capsule)
                .offset(y: -11)
                .padding(.trailing, 18)
        }
    }

    private func tagColors(_ tag: PaywallPlanTag) -> (background: Color, foreground: Color) {
        switch tag {
        case .popular:
            (popularBackground ?? tint, popularForeground ?? accentForeground)
        case .savings:
            (savingsBackground ?? tint, savingsForeground ?? accentForeground)
        }
    }

    private func tagText(_ tag: PaywallPlanTag) -> Text {
        switch tag {
        case .popular:
            popularTitle.map { Text($0) } ?? Text("Popular", bundle: .module)
        case .savings(let percent):
            Text("Save \((Double(percent) / 100).formatted(.percent.precision(.fractionLength(0))))", bundle: .module)
        }
    }
}
