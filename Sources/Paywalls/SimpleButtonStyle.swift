//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.03.25.
//

import SwiftUI

struct SimpleButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.secondary)
            .font(.system(size: 16, weight: .semibold))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
