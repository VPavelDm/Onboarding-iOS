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

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(viewModel.colorPalette.secondaryButtonForegroundColor)
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(viewModel.colorPalette.secondaryButtonBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(x: configuration.isPressed ? 0.95 : 1, y: configuration.isPressed ? 0.95 : 1)
            .opacity(isEnabled ? 1.0 : 0.65)
    }
}

#Preview {
    OneAnswerView(step: .testData())
        .preferredColorScheme(.dark)
}
