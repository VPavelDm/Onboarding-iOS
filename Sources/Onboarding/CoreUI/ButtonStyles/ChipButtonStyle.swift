//
//  File.swift
//  onboarding-ios
//

import SwiftUI

struct ChipButtonStyle: ButtonStyle {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel
    @Environment(\.isEnabled) var isEnabled

    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        let colorPalette = viewModel.colorPalette
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundStyle(colorPalette.textColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Capsule().fill(colorPalette.secondaryButtonBackground))
            .overlay {
                Capsule()
                    .strokeBorder(
                        isSelected
                            ? AnyShapeStyle(colorPalette.accentColor)
                            : AnyShapeStyle(colorPalette.secondaryButtonStrokeColor),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(isEnabled ? 1 : 0.65)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}
