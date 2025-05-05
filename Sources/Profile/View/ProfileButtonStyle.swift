//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 05.05.25.
//

import SwiftUI

struct ProfileButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 40)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}
