//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 02.11.24.
//

import SwiftUI

private struct DiscountWheelDraggableModifier: ViewModifier {

    @State private var wheelFrame: CGRect = .zero
    @State private var previousDraggingAngle: Angle = .zero

    @Binding var currentAngle: Angle
    var initialAngle: Angle
    @Binding var progress: CGFloat
    var coordinateSpace: CoordinateSpace

    private var wheelCenterPoint: CGPoint {
        CGPoint(
            x: wheelFrame.origin.x + wheelFrame.width / 2,
            y: wheelFrame.origin.y + wheelFrame.height / 2
        )
    }

    private let maxDraggingAngle: Angle = .degrees(720)

    private var animationDuration: TimeInterval {
        max(5, progress * 15)
    }

    func body(content: Content) -> some View {
        content
            .gesture(dragGesture)
            .readFrame(frame: $wheelFrame, coordinateSpace: coordinateSpace)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let currentDraggingPoint = value.location.convertCoordinates(to: wheelFrame.origin)
                let currentDraggingAngle = wheelCenterPoint.angle(to: currentDraggingPoint)
                guard previousDraggingAngle != .zero else {
                    return previousDraggingAngle = currentDraggingAngle
                }
                currentAngle.applyDelta(currentDraggingAngle - previousDraggingAngle)
                progress = min(abs(currentAngle.degrees / maxDraggingAngle.degrees), 1)
                previousDraggingAngle = currentDraggingAngle
            }
            .onEnded { _ in
                previousDraggingAngle = .zero
                withAnimation(.timingCurve(0.2, 0.8, 0.05, 1.0, duration: animationDuration)) {
                    currentAngle.onDragRelease(
                        initialAngle: initialAngle,
                        maxAngle: maxDraggingAngle,
                        progress: progress
                    )
                }
            }
    }
}

private extension CGPoint {

    func convertCoordinates(to point: CGPoint) -> CGPoint {
        CGPoint(
            x: point.x + x,
            y: point.y + y
        )
    }

    func angle(to point: CGPoint) -> Angle {
        let dx = point.x - x
        let dy = point.y - y
        let angle = atan2(dy, dx)
        return .radians(angle)
    }
}

private extension Angle {

    mutating func applyDelta(_ delta: Angle) {
        if delta.degrees > 180 {
            self += delta - .degrees(360)
        } else if delta.degrees < -180 {
            self += delta + .degrees(360)
        } else {
            self += delta
        }
    }

    mutating func onDragRelease(initialAngle: Angle, maxAngle: Angle, progress: CGFloat) {
        let isClockwise = self - initialAngle > .degrees(0)

        let maxEndAngle: CGFloat = isClockwise ? -5 - 360 * 6 : 320 + 360 * 5

        let circleAmounts = Int(progress * maxEndAngle / 360)

        let endAngle: CGFloat = maxEndAngle - CGFloat(360 * Int(maxEndAngle / 360)) + CGFloat(circleAmounts * 360)

        self = .degrees(endAngle)
    }
}

extension View {

    func draggable(
        currentAngle: Binding<Angle>,
        initialAngle: Angle,
        progress: Binding<CGFloat>,
        coordinateSpace: CoordinateSpace
    ) -> some View {
        modifier(DiscountWheelDraggableModifier(
            currentAngle: currentAngle,
            initialAngle: initialAngle,
            progress: progress,
            coordinateSpace: coordinateSpace
        ))
    }
}

#Preview {
    DiscountWheelStepView(step: .testData())
}
