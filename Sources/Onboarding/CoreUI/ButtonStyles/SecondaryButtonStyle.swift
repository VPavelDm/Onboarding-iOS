//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI

extension View {
    @ViewBuilder
    public func secondaryButtonStyle(colorPalette: ColorPalette) -> some View {
        buttonStyle(SecondaryButtonStyle(colorPalette: colorPalette))
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

public struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    private let colorPalette: ColorPalette

    public init(colorPalette: ColorPalette) {
        self.colorPalette = colorPalette
    }

    public func makeBody(configuration: Configuration) -> some View {
        secondaryButtonChrome(configuration.label, colorPalette: colorPalette, isPressed: configuration.isPressed, isEnabled: isEnabled, maxWidth: 500)
    }
}
