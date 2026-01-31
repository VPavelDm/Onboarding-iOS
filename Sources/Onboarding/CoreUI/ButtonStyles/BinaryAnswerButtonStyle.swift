//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import SwiftUI

struct BinaryAnswerButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.black)
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1.2, contentMode: .fit)
            .background(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(x: configuration.isPressed ? 0.95 : 1, y: configuration.isPressed ? 0.95 : 1)
    }
}

#Preview {
    BinaryAnswerView(step: .testData())
}
