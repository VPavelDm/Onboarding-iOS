//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled: Bool

    private let colorPalette: ColorPalette

    /// Keeps the button from stretching the whole width of a large screen.
    private static let maxWidth: CGFloat = 500

    public init(colorPalette: ColorPalette) {
        self.colorPalette = colorPalette
    }

    public func makeBody(configuration: Configuration) -> some View {
        let isDimmed = configuration.isPressed || !isEnabled
        configuration.label
            .foregroundStyle(colorPalette.primaryButtonForegroundColor)
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: Self.maxWidth)
            .frame(height: 54)
            .background(colorPalette.primaryButtonBackground.opacity(isDimmed ? 0.65 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(maxWidth: .infinity)
            .scaleEffect(x: configuration.isPressed ? 0.95 : 1, y: configuration.isPressed ? 0.95 : 1)
    }
}

#Preview {
    MockOnboardingView()
}
