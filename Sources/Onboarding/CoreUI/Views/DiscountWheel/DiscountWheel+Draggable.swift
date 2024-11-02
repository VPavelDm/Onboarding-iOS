//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 02.11.24.
//

import SwiftUI

private struct DiscountWheelDraggableModifier: ViewModifier {

    @State private var pressed: Bool = false
    @State private var progress: CGFloat = .zero
    
    @Binding var currentAngle: Angle

    func body(content: Content) -> some View {
        VStack(spacing: 32) {
            DiscountWheelProgressView(pressed: $pressed)
            content
            DiscountWheelLaunchButton(progress: $progress, pressed: $pressed)
            resetButton
        }
        .onChange(of: pressed) { [wasPressed = pressed] nowPressed in
            guard wasPressed && !nowPressed else { return }
            withAnimation(.timingCurve(0.2, 0.8, 0.05, 1.0, duration: 10)) {
                currentAngle = .degrees(-1805)
            }
        }
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

extension View {

    func draggable(currentAngle: Binding<Angle>) -> some View {
        modifier(DiscountWheelDraggableModifier(currentAngle: currentAngle))
    }
}

#Preview {
    DiscountWheelStepView(step: .testData())
}
