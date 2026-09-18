//
//  PaywallFeaturesView.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI

/// The host app's feature list, shown when the selected plan has no free trial.
struct PaywallFeaturesView: View {

    let features: [PaywallConfiguration.Feature]
    /// `.top` lines the checkmark up with the title, which is what a row with a
    /// subtitle wants; `.center` suits single-line rows.
    var alignment: VerticalAlignment = .top
    var textColor: Color = .white
    /// The checkmark disc colour; nil falls back to the accent color.
    var accent: Color?
    /// The glyph colour on a `.filled` disc.
    var accentForeground: Color = .white
    var iconStyle: PaywallConfiguration.FeatureIconStyle = .filled

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(features, id: \.self) { feature in
                featureRow(title: feature.title, subtitle: feature.subtitle)
            }
        }
        .padding(.horizontal, 4)
    }

    /// An empty subtitle is dropped rather than drawn: an empty `Text` still
    /// takes a line's height, which pushed the checkmark off the label on a
    /// host whose rows are titles only.
    private func featureRow(title: String, subtitle: String) -> some View {
        HStack(alignment: alignment, spacing: 12) {
            // 28 pt, down from 36: at 36 the four discs outweighed the 17 pt
            // labels beside them and the list read as a column of buttons.
            PaywallIconDisc(
                systemImage: "checkmark",
                tint: accent ?? Color.accentColor,
                foreground: accentForeground,
                style: iconStyle
            )
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(textColor)
                    .fixedSize(horizontal: false, vertical: true)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(textColor.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
    }
}
