//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.black)
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(x: configuration.isPressed ? 0.95 : 1, y: configuration.isPressed ? 0.95 : 1)
            .opacity(isEnabled ? 1.0 : 0.65)
    }
}
