//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 23.09.24.
//

import SwiftUI

struct DiscountWheelStepView: View {
    @Environment(\.colorPalette) private var colorPalette

    @State private var currentAngle: Angle = .initialAngle
    @State private var throwConfetti: Int = 0
    @State private var showSuccessAlert: Bool = false

    var body: some View {
        VStack {
            Spacer()
            titleView
            Spacer()
            DiscountWheel(currentAngle: $currentAngle, slices: .slices)
            Spacer()
            Spacer()
            spinButton
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorPalette.backgroundColor)
        .sensoryFeedback(feedbackType: .success, trigger: throwConfetti)
        .wheelSpinSensoryFeedback(
            currentAngle: $currentAngle,
            slicesCount: Array<DiscountWheel.Slice>.slices.count
        )
        .discountWheelConfetti(throwConfetti: $throwConfetti)
        .sheet(isPresented: $showSuccessAlert) {
            Text("Success")
                .presentationDetents([.medium])
        }
    }

    private var titleView: some View {
        Text("Spin to Win Your Prime Discount")
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .foregroundStyle(colorPalette.primaryTextColor)
    }

    private var spinButton: some View {
        AsyncButton {
            withAnimation(.timingCurve(0.2, 0.8, 0.2, 1.0, duration: 8)) {
                currentAngle = .degrees(-1840)
            }
            try? await Task.sleep(for: .seconds(8))
            throwConfetti = 1
            try? await Task.sleep(for: .milliseconds(500))
            throwConfetti += 1
            try? await Task.sleep(for: .milliseconds(500))
            throwConfetti += 1
            try? await Task.sleep(for: .milliseconds(500))
            showSuccessAlert = true
        } label: {
            Text("Spin")
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(currentAngle != .initialAngle)
    }
}

private extension Array where Element == DiscountWheel.Slice {

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
        let slices: [DiscountWheel.Slice] = .slices
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
    DiscountWheelStepView()
}
