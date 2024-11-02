//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 02.11.24.
//

import SwiftUI

struct DiscountWheelProgressView: View {
    @Environment(\.colorPalette) private var colorPalette

    @Binding var pressed: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .frame(height: 8)
                .foregroundStyle(colorPalette.progressBarBackgroundColor)
            RoundedRectangle(cornerRadius: 4)
                .frame(height: 8)
                .foregroundStyle(gradientColor)
                .frame(width: pressed ? .infinity : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
    }

    private var gradientColor: LinearGradient {
        LinearGradient(
            colors: [.green, .yellow, .red],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    DiscountWheelStepView(step: .testData())
}
