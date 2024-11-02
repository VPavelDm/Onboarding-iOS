//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 23.09.24.
//

import SwiftUI

struct DiscountWheelStepView: View {
    @Environment(\.colorPalette) private var colorPalette

    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var currentAngle: Angle = .initialAngle
    @State private var draggingProgress: CGFloat = .zero
    @State private var throwConfetti: Int = 0
    @State private var showSuccessAlert: Bool = false

    private var slices: [DiscountWheel.Slice] {
        .slices(colorPalette: colorPalette)
    }

    var step: DiscountWheelStep

    var body: some View {
        VStack {
            Spacer()
            titleView
            Spacer()
            wheelView
            Spacer()
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorPalette.backgroundColor)
        .sensoryFeedback(feedbackType: .success, trigger: throwConfetti)
        .wheelSpinSensoryFeedback(
            currentAngle: currentAngle,
            slicesCount: slices.count
        )
        .discountWheelConfetti(throwConfetti: $throwConfetti)
        .sheet(isPresented: $showSuccessAlert) {
            DiscountWheelSuccessView(isPresented: $showSuccessAlert, step: step)
                .environmentObject(viewModel)
        }
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .foregroundStyle(colorPalette.primaryTextColor)
    }

    private var wheelView: some View {
        DiscountWheel(currentAngle: $currentAngle, slices: slices)
            .draggable(currentAngle: $currentAngle)
    }
}

private extension Array where Element == DiscountWheel.Slice {

    static func slices(colorPalette: ColorPalette) -> [Element] {
        [
            Element(value: "5", color: colorPalette.discountSliceDarkColor),
            Element(value: "10", color: colorPalette.discountSliceLightColor),
            Element(value: "5", color: colorPalette.discountSliceDarkColor),
            Element(value: "25", color: colorPalette.discountSliceLightColor),
            Element(value: "5", color: colorPalette.discountSliceDarkColor),
            Element(value: "10", color: colorPalette.discountSliceLightColor),
            Element(value: "70", color: colorPalette.discountSliceGiftColor),
            Element(value: "5", color: colorPalette.discountSliceLightColor),
        ]
    }
}

extension Angle {

    static var initialAngle: Angle {
        let slices: [DiscountWheel.Slice] = .slices(colorPalette: .testData)
        return .degrees(360 / Double(slices.count)) / 2
    }
}

#Preview {
    DiscountWheelStepView(step: .testData())
}
