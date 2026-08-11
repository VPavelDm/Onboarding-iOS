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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(features, id: \.self) { feature in
                featureRow(title: feature.title, subtitle: feature.subtitle)
            }
        }
        .padding(.horizontal, 4)
    }

    private func featureRow(title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            checkmark
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private var checkmark: some View {
        ZStack {
            Circle().fill(Color.accentColor).frame(width: 36, height: 36)
            Image(systemName: "checkmark")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}
