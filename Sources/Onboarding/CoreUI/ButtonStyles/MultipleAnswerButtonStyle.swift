//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import SwiftUI

struct MultipleAnswerButtonStyle: ButtonStyle {
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
            .opacity(isEnabled ? 1.0 : 0.65)
    }
}
