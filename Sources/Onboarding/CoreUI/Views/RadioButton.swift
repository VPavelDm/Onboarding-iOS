//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 09.03.25.
//

import SwiftUI

struct RadioButton: View {

    var colorPalette: any ColorPalette
    @Binding var isSelected: Bool

    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(colorPalette.primaryButtonBackground)
                    .padding(4)
            }
            Circle()
                .stroke(colorPalette.primaryButtonBackground, lineWidth: 2)
        }
        .frame(width: 20, height: 20)
        .animation(.easeInOut, value: isSelected)
    }
}
