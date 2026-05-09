//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    private let colorPalette: ColorPalette

    public init(colorPalette: ColorPalette) {
        self.colorPalette = colorPalette
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(colorPalette.primaryButtonForegroundColor)
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: 500)
            .frame(height: 54)
            .background(colorPalette.primaryButtonBackground.opacity(configuration.isPressed || !isEnabled ? 0.65 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(maxWidth: .infinity)
            .scaleEffect(x: configuration.isPressed ? 0.95 : 1, y: configuration.isPressed ? 0.95 : 1)
    }
}

#Preview {
    MockOnboardingView()
}
