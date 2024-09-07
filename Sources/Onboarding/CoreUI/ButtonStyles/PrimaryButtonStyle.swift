//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.colorPalette) private var colorPalette
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(colorPalette.primaryButtonTextColor)
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(colorPalette.primaryButtonBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(x: configuration.isPressed ? 0.95 : 1, y: configuration.isPressed ? 0.95 : 1)
            .opacity(isEnabled ? 1.0 : 0.65)
    }
}
