//
//  PaywallTimelineView.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI

/// "How your free trial works" — a three-step vertical timeline shown when the
/// selected plan offers a trial. Day labels derive from the trial length; the first
/// and last step bodies are the host's copy.
struct PaywallTimelineView: View {
    let trialDays: Int
    let unlockBody: String
    let trialEndBody: String
    var textColor: Color = .white
    /// The step disc colour; nil falls back to the accent color.
    var accent: Color?
    /// The glyph colour on a `.filled` disc.
    var accentForeground: Color = .white
    var iconStyle: PaywallConfiguration.FeatureIconStyle = .filled
    /// Host copy for the middle step; nil keeps the library's reminder wording.
    /// `{day}` is replaced by the step's day number.
    var midTitle: String?
    var midBody: String?
    var midIcon: String?
    var startTitle: String?
    /// `{day}` is the trial's length.
    var endTitle: String?

    /// `.neutral` draws its discs a size up, as `PaywallIconDisc` does.
    private var discSize: CGFloat { iconStyle == .neutral ? 36 : 28 }
    private var railWidth: CGFloat { iconStyle == .neutral ? 2 : 3 }

    /// The day before the trial ends — when the store sends its own renewal notice, and the last
    /// day a cancellation still costs nothing.
    private var reminderDay: Int { max(1, trialDays - 1) }

    private func withDay(_ text: String) -> String {
        text.replacingOccurrences(of: "{day}", with: String(reminderDay))
    }

    /// The day the trial ends, counted from today: "Oct 24".
    private var trialEndDate: String {
        let date = Calendar.current.date(byAdding: .day, value: trialDays, to: .now) ?? .now
        return date.formatted(.dateTime.month(.abbreviated).day())
    }

    private var tint: Color { accent ?? .accentColor }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            item(
                icon: "lock.open.fill",
                title: startTitle ?? String(localized: "Today — full access", bundle: .module),
                body: unlockBody,
                tint: tint,
                nextTint: tint
            )
            item(
                icon: midIcon ?? "bell.fill",
                title: midTitle.map(withDay) ?? String(localized: "Day \(reminderDay) — reminder", bundle: .module),
                body: midBody.map(withDay) ?? String(localized: "We'll remind you before your trial ends. Cancel anytime.", bundle: .module),
                tint: tint,
                nextTint: tint.opacity(0.5)
            )
            item(
                icon: "star.fill",
                title: endTitle.map { $0.replacingOccurrences(of: "{day}", with: String(trialDays)) }
                    ?? String(localized: "Day \(trialDays) — trial ends", bundle: .module),
                body: trialEndBody.replacingOccurrences(of: "{date}", with: trialEndDate),
                tint: tint.opacity(0.5),
                nextTint: nil
            )
        }
        .padding(.horizontal, 4)
    }

    private func item(icon: String, title: String, body: String, tint: Color, nextTint: Color?) -> some View {
        HStack(alignment: .top, spacing: 12) {
            PaywallIconDisc(systemImage: icon, tint: tint, foreground: accentForeground, style: iconStyle == .glyph ? .tinted : iconStyle, size: discSize, neutralColor: textColor)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(textColor)
                    .fixedSize(horizontal: false, vertical: true)
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(textColor.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, nextTint == nil ? 0 : 16)
            Spacer(minLength: 0)
        }
        .background(alignment: .topLeading) {
            // The rail is a background filling the row's real height below the
            // disc, so it reaches the next disc no matter how the text wraps —
            // a fixed-height connector fell short on taller rows.
            if let nextTint {
                connector(from: tint, to: nextTint)
                    .padding(.leading, (discSize - railWidth) / 2)
                    .padding(.top, discSize)
            }
        }
    }

    private func connector(from: Color, to: Color) -> some View {
        Rectangle()
            .fill(iconStyle == .neutral
                ? AnyShapeStyle(textColor.opacity(0.12))
                : AnyShapeStyle(LinearGradient(colors: [from.opacity(0.5), to.opacity(0.5)], startPoint: .top, endPoint: .bottom)))
            .frame(width: railWidth)
    }
}
