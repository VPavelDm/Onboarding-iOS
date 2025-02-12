//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 02.11.24.
//

import SwiftUI

struct DiscountWheelLaunchButton: View {

    @State private var scaleFactor: CGFloat = 1
    @State private var pressedAt: Date?

    @Binding var progress: CGFloat
    @Binding var pressed: Bool
    @Binding var pressingProgress: Double
    var step: DiscountWheelStep

    var body: some View {
        Text(step.spinButtonTitle)
            .foregroundStyle(.white)
            .font(.system(size: 16, weight: .semibold))
            .padding()
            .background(.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(x: scaleFactor, y: scaleFactor)
            .onLongPressGesture {
            } onPressingChanged: { isPressed in
                if isPressed {
                    onPressing()
                } else {
                    onReleased()
                }
            }
            .disabled(progress != .zero)
    }

    private func onPressing() {
        pressedAt = Date()
        withAnimation(.linear(duration: .maxPressDuration)) {
            pressed = true
            scaleFactor = .targetScaleFactor
            pressingProgress = 100
        }
    }

    private func onReleased() {
        guard let pressedAt else { return }
        let pressingDuration = Date().timeIntervalSince(pressedAt)
        progress = pressingDuration / .maxPressDuration
        withAnimation {
            pressed = false
            scaleFactor = 1
        }
    }
}

// MARK: - Constants

private extension TimeInterval {

    static let maxPressDuration: CGFloat = 3
}

private extension CGFloat {

    static let targetScaleFactor = 0.9
}

#Preview {
    DiscountWheelStepView(step: .testData())
        .preferredColorScheme(.dark)
}
