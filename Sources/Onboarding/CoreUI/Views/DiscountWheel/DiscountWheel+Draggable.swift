//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 02.11.24.
//

import SwiftUI

private struct DiscountWheelDraggableModifier: ViewModifier {

    @State private var pressed: Bool = false

    @Binding var progress: CGFloat
    @Binding var currentAngle: Angle

    func body(content: Content) -> some View {
        VStack(spacing: 32) {
            MyProgressBarView(pressed: $pressed)
            content
            launchButton
        }
        .onChange(of: pressed) { [wasPressed = pressed] nowPressed in
            guard wasPressed && !nowPressed else { return }
            withAnimation(.timingCurve(0.2, 0.8, 0.05, 1.0, duration: 10)) {
                currentAngle = .degrees(-1805)
            }
        }
    }

    private var launchButton: some View {
        DiscountWheelLaunchButton(progress: $progress, pressed: $pressed)
    }

}

extension View {

    func draggable(
        currentAngle: Binding<Angle>,
        initialAngle: Angle,
        progress: Binding<CGFloat>,
        coordinateSpace: CoordinateSpace
    ) -> some View {
        modifier(DiscountWheelDraggableModifier(progress: progress, currentAngle: currentAngle))
    }
}

#Preview {
    DiscountWheelStepView(step: .testData())
}
