//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 25.09.24.
//

import SwiftUI
import ConfettiSwiftUI

private struct DiscountWheelConfettiModifier: ViewModifier {

    @Binding var throwConfetti: Int

    func body(content: Content) -> some View {
        content
            .overlay(
                confettiView(angle: .leftConfettiAngle)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            )
            .overlay(
                confettiView(angle: .rightConfettiAngle)
                    .frame(maxWidth: .infinity, alignment: .leading)
            )
    }

    private func confettiView(angle: Angle) -> some View {
        Rectangle()
            .fill(.clear)
            .frame(width: 10)
            .confettiCannon(
                counter: $throwConfetti,
                num: 15,
                confettiSize: .size,
                openingAngle: angle,
                closingAngle: angle,
                radius: .radius
            )
    }
}

private extension CGFloat {

    static var radius: CGFloat { 600 }
    static var size: CGFloat { 25 }
}

private extension Angle {

    static var leftConfettiAngle: Angle {
        .degrees(120)
    }

    static var rightConfettiAngle: Angle {
        .degrees(60)
    }
}

extension View {

    func discountWheelConfetti(throwConfetti: Binding<Int>) -> some View {
        modifier(DiscountWheelConfettiModifier(throwConfetti: throwConfetti))
    }
}

#Preview {
    DiscountWheelStepView(step: .testData())
}
