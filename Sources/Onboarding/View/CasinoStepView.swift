//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 23.09.24.
//

import SwiftUI

struct CasinoStepView: View {
    @Environment(\.colorPalette) private var colorPalette

    @State private var currentAngle: Angle = .initialAngle
    @State private var throwConfetti: Bool = false

    var body: some View {
        VStack {
            Spacer()
            titleView
            Spacer()
            CasinoWheel(currentAngle: $currentAngle, slices: .slices)
            Spacer()
            Spacer()
            if #available(iOS 17.0, *) {
                spinButton
            } else {
                spinButtonIOS16
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorPalette.backgroundColor)
        .casinoWheelConfetti(throwConfetti: $throwConfetti)
    }

    private var titleView: some View {
        Text("Spin to Win Your Prime Discount")
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .foregroundStyle(colorPalette.primaryTextColor)
    }

    @available(iOS 17.0, *)
    private var spinButton: some View {
        Button {
            withAnimation(.timingCurve(0.2, 0.8, 0.2, 1.0, duration: 5)) {
                currentAngle = .degrees(-760)
            } completion: {
                throwConfetti = true
            }
        } label: {
            Text("Spin")
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    private var spinButtonIOS16: some View {
        Button {
            withAnimation(.timingCurve(0.2, 0.8, 0.2, 1.0, duration: 5)) {
                currentAngle = .degrees(-760)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                throwConfetti = true
            }
        } label: {
            Text("Spin")
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

private extension Array where Element == CasinoWheel.Slice {

    static var slices: [Element] {
        [
            Element(value: "5", color: .darkSlice),
            Element(value: "10", color: .lightSlice),
            Element(value: "5", color: .darkSlice),
            Element(value: "25", color: .lightSlice),
            Element(value: "5", color: .darkSlice),
            Element(value: "10", color: .lightSlice),
            Element(value: "75", color: .gift),
            Element(value: "5", color: .lightSlice),
        ]
    }
}

private extension Angle {

    static var initialAngle: Angle {
        let slices: [CasinoWheel.Slice] = .slices
        return .degrees(360 / Double(slices.count)) / 2
    }
}

private extension Color {

    static var darkSlice: Color {
        Color(hex: "4D5761")
    }

    static var lightSlice: Color {
        Color(hex: "6C737F")
    }

    static var gift: Color {
        Color(hex: "EF5350")
    }
}

#Preview {
    CasinoStepView()
}
