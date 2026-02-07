//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 08.09.24.
//

import SwiftUI

struct AnswerButtonStyle: ButtonStyle {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @Environment(\.isEnabled) private var isEnabled

    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(viewModel.colorPalette.secondaryButtonForegroundColor)
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 64)
            .padding(.horizontal)
            .background(viewModel.colorPalette.secondaryButtonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? viewModel.colorPalette.primaryButtonBackground : AnyShapeStyle(viewModel.colorPalette.secondaryButtonStrokeColor), lineWidth: 2)
            }
            .scaleEffect(x: configuration.isPressed ? 0.95 : 1, y: configuration.isPressed ? 0.95 : 1)
            .opacity(isEnabled ? 1.0 : 0.65)
    }
}
