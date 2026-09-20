//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI

extension View {
    @ViewBuilder
    public func primaryButtonStyle(colorPalette: ColorPalette) -> some View {
        buttonStyle(PrimaryButtonStyle(colorPalette: colorPalette))
    }

}

@ViewBuilder
private func primaryButtonChrome<V: View>(
    _ view: V,
    colorPalette: ColorPalette,
    isPressed: Bool,
    isEnabled: Bool,
    maxWidth: CGFloat
) -> some View {
    view
        .foregroundStyle(colorPalette.primaryButtonForegroundColor)
        .font(.system(size: 16, weight: .semibold))
        .frame(maxWidth: maxWidth)
        .frame(height: 54)
        .background(colorPalette.primaryButtonBackground.opacity(isPressed || !isEnabled ? 0.65 : 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: .infinity)
        .scaleEffect(x: isPressed ? 0.95 : 1, y: isPressed ? 0.95 : 1)
}

public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled: Bool

    private let colorPalette: ColorPalette

    public init(colorPalette: ColorPalette) {
        self.colorPalette = colorPalette
    }

    public func makeBody(configuration: Configuration) -> some View {
        primaryButtonChrome(
            configuration.label,
            colorPalette: colorPalette,
            isPressed: configuration.isPressed,
            isEnabled: isEnabled,
            maxWidth: 500
        )
    }
}

#Preview {
    MockOnboardingView()
}
