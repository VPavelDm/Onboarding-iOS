//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorPalette) private var colorPalette

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(colorPalette.secondaryButtonTextColor)
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(colorPalette.secondaryButtonBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(x: configuration.isPressed ? 0.95 : 1, y: configuration.isPressed ? 0.95 : 1)
            .opacity(isEnabled ? 1.0 : 0.65)
    }
}
