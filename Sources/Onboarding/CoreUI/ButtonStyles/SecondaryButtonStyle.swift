//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI

extension View {
    @ViewBuilder
    func secondaryButtonStyleCompat(colorPalette: ColorPalette) -> some View {
        #if os(Android)
        secondaryButtonChrome(buttonStyle(.plain), colorPalette: colorPalette, isPressed: false, isEnabled: true, maxWidth: .infinity)
        #else
        buttonStyle(SecondaryButtonStyle())
        #endif
    }
}

@ViewBuilder
private func secondaryButtonChrome<V: View>(_ view: V, colorPalette: ColorPalette, isPressed: Bool, isEnabled: Bool, maxWidth: CGFloat) -> some View {
    view
        .foregroundStyle(colorPalette.secondaryButtonForegroundColor)
        .font(.system(size: 16, weight: .semibold))
        .frame(maxWidth: maxWidth)
        .frame(height: 54)
        .background(colorPalette.secondaryButtonBackground.opacity(isPressed || !isEnabled ? 0.65 : 1))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorPalette.secondaryButtonStrokeColor, lineWidth: 4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: .infinity)
        .scaleEffect(x: isPressed ? 0.95 : 1, y: isPressed ? 0.95 : 1)
}

#if !os(Android)
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        secondaryButtonChrome(configuration.label, colorPalette: viewModel.colorPalette, isPressed: configuration.isPressed, isEnabled: isEnabled, maxWidth: 500)
    }
}
#endif
