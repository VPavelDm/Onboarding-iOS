//
//  TimePickerButtonStyle.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 28.10.24.
//

import SwiftUI
import CoreUI

struct TimePickerButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: 500)
            .frame(height: 54)
            .background(Color(hex: "4743A3"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(maxWidth: .infinity)
            .scaleEffect(x: configuration.isPressed ? 0.95 : 1, y: configuration.isPressed ? 0.95 : 1)
            .opacity(isEnabled ? 1.0 : 0.65)
    }
}

#Preview {
    WheelTimePicker(step: .testData(), completion: { _ in })
}
