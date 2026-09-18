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
    /// The checkmark circle fill; defaults to the accent color.
    var iconBackground: Color?
    /// The checkmark glyph color inside the circle.
    var iconColor: Color = .white

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
        HStack(alignment: alignment, spacing: 14) {
            checkmark
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(textColor)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(textColor.opacity(0.75))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var checkmark: some View {
        ZStack {
            Circle().fill(iconBackground ?? Color.accentColor).frame(width: 36, height: 36)
            Image(systemName: "checkmark")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(iconColor)
        }
    }
}
