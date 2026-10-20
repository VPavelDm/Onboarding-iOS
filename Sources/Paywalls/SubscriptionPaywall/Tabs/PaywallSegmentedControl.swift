//
//  PaywallSegmentedControl.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import SwiftUI

/// The tabs under a tabbed paywall's headline: the titles as segments of one
/// capsule, the accent sliding to the chosen one. Drawn from the paywall's
/// own colours (`PaywallConfiguration`): the chosen segment in the accent
/// with the accent's text colour on it, the rest in the text colour on a
/// faint track.
struct PaywallSegmentedControl: View {
    let titles: [String]
    let selectedIndex: Int
    let textColor: Color
    let accent: Color
    let accentForeground: Color
    let onSelect: (Int) -> Void

    /// Slim enough for the band beside the corner close.
    static let height: CGFloat = 32
    static let maxWidth: CGFloat = 210

    @Namespace private var indicator

    var body: some View {
        HStack(spacing: 4) {
            ForEach(titles.indices, id: \.self) { index in
                Button {
                    onSelect(index)
                } label: {
                    Text(titles[index])
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .buttonStyle(SegmentButtonStyle(
                    isSelected: index == selectedIndex,
                    textColor: textColor,
                    accent: accent,
                    accentForeground: accentForeground,
                    indicator: indicator
                ))
            }
        }
        .padding(4)
        .background(Capsule().fill(textColor.opacity(0.1)))
        .overlay(Capsule().stroke(textColor.opacity(0.08), lineWidth: 1))
        .frame(maxWidth: Self.maxWidth)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedIndex)
    }
}

/// One segment: the accent's text colour on the sliding accent when chosen,
/// the text colour on nothing otherwise.
private struct SegmentButtonStyle: ButtonStyle {
    var isSelected: Bool
    var textColor: Color
    var accent: Color
    var accentForeground: Color
    var indicator: Namespace.ID

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? accentForeground : textColor)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: PaywallSegmentedControl.height)
            .background {
                if isSelected {
                    Capsule()
                        .fill(accent)
                        .matchedGeometryEffect(id: "segment", in: indicator)
                }
            }
            .contentShape(Capsule())
            .opacity(configuration.isPressed && !isSelected ? 0.6 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
