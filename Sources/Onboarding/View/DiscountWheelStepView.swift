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
    @State private var throwConfetti: Int = 0
    @State private var showSuccessAlert: Bool = false
    @State private var pressed: Bool = false
    @State private var progress: CGFloat = .zero

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
            resetButton
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
        VStack(spacing: 32) {
            DiscountWheelProgressView(pressed: $pressed)
            DiscountWheel(currentAngle: $currentAngle, slices: slices)
            VStack(spacing: 16) {
                DiscountWheelLaunchButton(progress: $progress, pressed: $pressed)
                explanationView
            }
        }
        .onChange(of: pressed) { [wasPressed = pressed] nowPressed in
            guard wasPressed && !nowPressed else { return }
            withAnimation(.timingCurve(0.2, 0.8, 0.05, 1.0, duration: 10)) {
                currentAngle = .degrees(-1805)
            }
        }
    }

    private var explanationView: some View {
        Text("Press and hold to Power Up the wheel and to win your Discount")
            .foregroundStyle(colorPalette.secondaryTextColor)
            .font(.footnote)
            .multilineTextAlignment(.center)
            .opacity(0.5)
    }

    private var resetButton: some View {
        Button {
            currentAngle = .initialAngle
            progress = .zero
        } label: {
            Text("Reset")
        }
        .buttonStyle(PrimaryButtonStyle())
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

private extension Angle {

    static var initialAngle: Angle {
        let slices: [DiscountWheel.Slice] = .slices(colorPalette: .testData)
        return .degrees(360 / Double(slices.count)) / 2
    }
}

#Preview {
    DiscountWheelStepView(step: .testData())
}
