//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 23.09.24.
//

import SwiftUI

struct DiscountWheelStepView: View {

    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var currentAngle: Angle = .initialAngle
    @State private var throwConfetti: Int = 0
    @State private var showSuccessAlert: Bool = false
    @State private var pressed: Bool = false
    @State private var progress: CGFloat = .zero
    @State private var pressingProgress: Double = 0

    private var slices: [DiscountWheel.Slice] { .slices }

    private var animationDuration: TimeInterval {
        guard progress > .minSpinProgress else { return 5 }
        return max(progress * 15, 10)
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
        .background(.black)
        .sensoryFeedback(feedbackType: .success, trigger: throwConfetti)
        .pressSensoryFeedback(progress: pressingProgress)
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
            .foregroundStyle(.white)
    }

    private var wheelView: some View {
        VStack(spacing: 32) {
            DiscountWheelProgressView(pressed: $pressed)
            DiscountWheel(currentAngle: $currentAngle, slices: slices)
            VStack(spacing: 16) {
                DiscountWheelLaunchButton(
                    progress: $progress,
                    pressed: $pressed,
                    pressingProgress: $pressingProgress,
                    step: step
                )
                explanationView
            }
        }
        .onChange(of: pressed) { [wasPressed = pressed] nowPressed in
            guard !wasPressed && nowPressed else { return }
            withAnimation(.linear) {
                currentAngle += .degrees(2)
            }
        }
        .onChange(of: pressed) { [wasPressed = pressed] nowPressed in
            guard wasPressed && !nowPressed else { return }
            if #available(iOS 17.0, *) {
                withAnimation(.timingCurve(0.2, 0.8, 0.05, 1.0, duration: animationDuration)) {
                    currentAngle = .onHoldRelease(progress: progress)
                } completion: {
                    guard progress > .minSpinProgress else { return }
                    initiateSuccessAlert()
                }
            } else {
                withAnimation(.timingCurve(0.2, 0.8, 0.05, 1.0, duration: animationDuration)) {
                    currentAngle = .onHoldRelease(progress: progress)
                }
                Task { @MainActor in
                    guard progress > .minSpinProgress else { return }
                    try? await Task.sleep(for: .seconds(animationDuration + 0.5))
                    initiateSuccessAlert()
                }
            }
        }
    }

    private var explanationView: some View {
        Text(step.spinFootnote)
            .foregroundStyle(.white)
            .font(.footnote)
            .multilineTextAlignment(.center)
            .opacity(0.5)
    }

    private func initiateSuccessAlert() {
        Task { @MainActor in
            throwConfetti = 1
            try? await Task.sleep(for: .milliseconds(500))
            throwConfetti += 1
            try? await Task.sleep(for: .milliseconds(500))
            throwConfetti += 1
            try? await Task.sleep(for: .milliseconds(500))
            showSuccessAlert = true
        }
    }
}

private extension Array where Element == DiscountWheel.Slice {

    static var slices: [Element] {
        [
            Element(value: "7", color: Color(hex: "4D5761")),
            Element(value: "10", color: Color(hex: "6C727E")),
            Element(value: "5", color: Color(hex: "4D5761")),
            Element(value: "25", color: Color(hex: "6C727E")),
            Element(value: "5", color: Color(hex: "4D5761")),
            Element(value: "10", color: Color(hex: "6C727E")),
            Element(value: "92", color: Color(hex: "EE534F")),
            Element(value: "5", color: Color(hex: "6C727E")),
        ]
    }
}

private extension Angle {

    static var initialAngle: Angle {
        let slices: [DiscountWheel.Slice] = .slices
        return .degrees(360 / Double(slices.count)) / 2 * 3
    }

    static func onHoldRelease(progress: CGFloat) -> Angle {
        if progress > .minSpinProgress {
            let maxEndAngle: CGFloat = 320 + 360 * 7

            let circleAmounts = Int(progress * maxEndAngle / 360)

            let endAngle: CGFloat = maxEndAngle - CGFloat(360 * Int(maxEndAngle / 360)) + CGFloat(circleAmounts * 360)

            return .degrees(endAngle)
        } else {
            return .initialAngle + .degrees(15)
        }
    }
}

// MARK: - Constants

extension CGFloat {

    static var minSpinProgress: CGFloat = 0.2
}

#Preview {
    DiscountWheelStepView(step: .testData())
        .preferredColorScheme(.dark)
}
