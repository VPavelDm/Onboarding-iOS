//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    @Environment(\.isEnabled) private var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(viewModel.colorPalette.primaryButtonForegroundColor)
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: 500)
            .padding()
            .background(viewModel.colorPalette.primaryButtonBackgroundColor.opacity(configuration.isPressed || !isEnabled ? 0.65 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(maxWidth: .infinity)
            .scaleEffect(x: configuration.isPressed ? 0.95 : 1, y: configuration.isPressed ? 0.95 : 1)
    }
}

#Preview {
    MultipleAnswerView(step: .testData())
        .preferredColorScheme(.dark)
}
