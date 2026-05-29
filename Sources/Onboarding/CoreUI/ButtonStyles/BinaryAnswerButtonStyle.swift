//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import SwiftUI

extension View {
    @ViewBuilder
    func binaryAnswerButtonStyleCompat() -> some View {
        #if os(Android)
        binaryAnswerButtonChrome(buttonStyle(.plain), isPressed: false)
        #else
        buttonStyle(BinaryAnswerButtonStyle())
        #endif
    }
}

@ViewBuilder
private func binaryAnswerButtonChrome<V: View>(_ view: V, isPressed: Bool) -> some View {
    view
        .foregroundStyle(.black)
        .font(.system(size: 16, weight: .semibold))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1.2, contentMode: .fit)
        .background(.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .scaleEffect(x: isPressed ? 0.95 : 1, y: isPressed ? 0.95 : 1)
}

#if !os(Android)
struct BinaryAnswerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        binaryAnswerButtonChrome(configuration.label, isPressed: configuration.isPressed)
    }
}

#Preview {
    BinaryAnswerView(step: .testData())
}
#endif
