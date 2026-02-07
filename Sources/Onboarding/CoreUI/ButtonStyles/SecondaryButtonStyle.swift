//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(viewModel.colorPalette.secondaryButtonForegroundColor)
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: 500)
            .frame(height: 54)
            .background(viewModel.colorPalette.secondaryButtonBackground.opacity(configuration.isPressed || !isEnabled ? 0.65 : 1))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(viewModel.colorPalette.secondaryButtonStrokeColor, lineWidth: 4)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(maxWidth: .infinity)
            .scaleEffect(x: configuration.isPressed ? 0.95 : 1, y: configuration.isPressed ? 0.95 : 1)
    }
}
