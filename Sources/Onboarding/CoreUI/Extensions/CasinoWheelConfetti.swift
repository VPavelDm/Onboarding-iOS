//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 25.09.24.
//

import SwiftUI
import ConfettiSwiftUI

private struct CasinoWheelConfettiModifier: ViewModifier {

    @State private var counter: Int = 0

    @Binding var throwConfetti: Bool

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
            .onChange(of: throwConfetti) { throwConfetti in
                if throwConfetti {
                    counter += 1
                }
            }
    }

    private func confettiView(angle: Angle) -> some View {
        Rectangle()
            .fill(.clear)
            .frame(width: 10)
            .confettiCannon(
                counter: $counter,
                num: 15,
                confettiSize: .size,
                openingAngle: angle,
                closingAngle: angle,
                radius: .radius,
                repetitions: .repetitions
            )
    }
}

private extension CGFloat {

    static var radius: CGFloat { 600 }
    static var size: CGFloat { 25 }
}

private extension Int {
    static var repetitions: Int { 2 }
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

    func casinoWheelConfetti(throwConfetti: Binding<Bool>) -> some View {
        modifier(CasinoWheelConfettiModifier(throwConfetti: throwConfetti))
    }
}

#Preview {
    CasinoStepView()
}
