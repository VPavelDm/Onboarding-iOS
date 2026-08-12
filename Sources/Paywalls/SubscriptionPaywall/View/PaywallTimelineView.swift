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
    /// The step circle fill; defaults to the accent color.
    var iconBackground: Color?
    /// The step icon glyph color inside the circles.
    var iconColor: Color = .white

    private var reminderDay: Int { max(1, trialDays - 2) }

    private var circleFill: Color { iconBackground ?? .accentColor }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            item(
                icon: "lock.open.fill",
                title: String(localized: "Today — full access", bundle: .module),
                body: unlockBody,
                tint: circleFill,
                nextTint: circleFill
            )
            item(
                icon: "bell.fill",
                title: String(localized: "Day \(reminderDay) — reminder", bundle: .module),
                body: String(localized: "We'll remind you before your trial ends. Cancel anytime.", bundle: .module),
                tint: circleFill,
                nextTint: circleFill.opacity(0.5)
            )
            item(
                icon: "star.fill",
                title: String(localized: "Day \(trialDays) — trial ends", bundle: .module),
                body: trialEndBody,
                tint: circleFill.opacity(0.5),
                nextTint: nil
            )
        }
        .padding(.horizontal, 4)
    }

    private func item(icon: String, title: String, body: String, tint: Color, nextTint: Color?) -> some View {
        HStack(alignment: .top, spacing: 14) {
            iconCircle(icon: icon, tint: tint)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(textColor)
                    .fixedSize(horizontal: false, vertical: true)
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(textColor.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, nextTint == nil ? 0 : 18)
            Spacer(minLength: 0)
        }
        .background(alignment: .topLeading) {
            // The rail is a background filling the row's real height below the
            // circle, so it reaches the next bubble no matter how the text
            // wraps — a fixed-height connector fell short on taller rows.
            if let nextTint {
                connector(from: tint, to: nextTint)
                    .padding(.leading, 15)
                    .padding(.top, 36)
            }
        }
    }

    private func iconCircle(icon: String, tint: Color) -> some View {
        ZStack {
            Circle().fill(tint).frame(width: 36, height: 36)
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(iconColor)
        }
    }

    private func connector(from: Color, to: Color) -> some View {
        Rectangle()
            .fill(LinearGradient(colors: [from.opacity(0.5), to.opacity(0.5)], startPoint: .top, endPoint: .bottom))
            .frame(width: 6)
    }
}
