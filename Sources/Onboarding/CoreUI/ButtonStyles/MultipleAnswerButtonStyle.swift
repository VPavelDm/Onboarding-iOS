//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import SwiftUI

struct MultipleAnswerButtonStyle: ButtonStyle {
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
            .background(viewModel.colorPalette.secondaryButtonBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? viewModel.colorPalette.primaryButtonBackgroundColor : viewModel.colorPalette.secondaryButtonStrokeColor, lineWidth: 2)
            }
            .opacity(isEnabled ? 1.0 : 0.65)
    }
}
