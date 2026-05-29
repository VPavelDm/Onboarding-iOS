//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import SwiftUI

extension View {
    @ViewBuilder
    func multipleAnswerButtonStyleCompat(colorPalette: ColorPalette, isSelected: Bool) -> some View {
        #if os(Android)
        multipleAnswerButtonChrome(buttonStyle(.plain), colorPalette: colorPalette, isSelected: isSelected, isPressed: false, isEnabled: true)
        #else
        buttonStyle(MultipleAnswerButtonStyle(isSelected: isSelected))
        #endif
    }
}

@ViewBuilder
private func multipleAnswerButtonChrome<V: View>(_ view: V, colorPalette: ColorPalette, isSelected: Bool, isPressed: Bool, isEnabled: Bool) -> some View {
    view
        .foregroundStyle(colorPalette.secondaryButtonForegroundColor)
        .font(.system(size: 16, weight: .semibold))
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 64)
        .padding(.horizontal)
        .background(colorPalette.secondaryButtonBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? colorPalette.primaryButtonBackground : AnyShapeStyle(colorPalette.secondaryButtonStrokeColor), lineWidth: 2)
        }
        .scaleEffect(x: isPressed ? 0.95 : 1, y: isPressed ? 0.95 : 1)
        .opacity(isEnabled ? 1.0 : 0.65)
}

#if !os(Android)
struct MultipleAnswerButtonStyle: ButtonStyle {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel
    @Environment(\.isEnabled) var isEnabled

    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        multipleAnswerButtonChrome(configuration.label, colorPalette: viewModel.colorPalette, isSelected: isSelected, isPressed: configuration.isPressed, isEnabled: isEnabled)
    }
}
#endif
