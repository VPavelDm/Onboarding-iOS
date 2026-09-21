//
//  File.swift
//  onboarding-ios
//

import SwiftUI

struct CardGridTileButtonStyle: ButtonStyle {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel
    @Environment(\.isEnabled) var isEnabled

    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        let colorPalette = viewModel.colorPalette
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(colorPalette.secondaryButtonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [colorPalette.textColor.opacity(0.35), colorPalette.textColor.opacity(0)],
                            startPoint: .top,
                            endPoint: .center
                        ),
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)
            }
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(colorPalette.accentColor, lineWidth: 2)
                }
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(colorPalette.accentColor)
                        .padding(8)
                }
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(isEnabled ? 1 : 0.65)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
