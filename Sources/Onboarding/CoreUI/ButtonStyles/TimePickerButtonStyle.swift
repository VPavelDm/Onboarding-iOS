//
//  TimePickerButtonStyle.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 28.10.24.
//

import SwiftUI
import CoreUI

struct TimePickerButtonStyle: ButtonStyle {
    @Environment(\.colorPalette) private var colorPalette
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(colorPalette.primaryButtonTextColor)
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "4743A3"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(x: configuration.isPressed ? 0.95 : 1, y: configuration.isPressed ? 0.95 : 1)
            .opacity(isEnabled ? 1.0 : 0.65)
    }
}