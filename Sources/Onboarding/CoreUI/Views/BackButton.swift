//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 07.09.24.
//

import SwiftUI
import CoreUI

struct BackButton: View {
    @Environment(\.colorPalette) private var colorPalette
    @State private var isAnimationInProgress: Bool = false

    var action: () -> Void

    var body: some View {
        AsyncButton {
            action()
            isAnimationInProgress = true
            try? await Task.sleep(for: .milliseconds(350))
            isAnimationInProgress = false
        } label: {
            Image(systemName: "chevron.compact.left")
                .resizable()
                .font(.system(size: 12, weight: .light))
                .frame(width: 12, height: 16)
                .frame(width: 20)
                .foregroundStyle(colorPalette.primaryTextColor)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isAnimationInProgress)
    }
}
