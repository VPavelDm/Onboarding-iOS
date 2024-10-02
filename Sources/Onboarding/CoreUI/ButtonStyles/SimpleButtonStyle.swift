//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 02.10.24.
//

import SwiftUI

struct SimpleButtonStyle: ButtonStyle {
    @Environment(\.colorPalette) private var colorPalette
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(colorPalette.primaryButtonTextColor.opacity(configuration.isPressed || isEnabled ? 0.65 : 1))
            .font(.system(size: 16, weight: .semibold))
    }
}
