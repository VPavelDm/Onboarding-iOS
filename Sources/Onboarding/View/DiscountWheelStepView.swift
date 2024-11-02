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

    private var slices: [DiscountWheel.Slice] {
        .slices(colorPalette: colorPalette)
    }

    var step: DiscountWheelStep

    var body: some View {
        VStack {
            Spacer()
            titleView
            Spacer()
            DiscountWheel(currentAngle: $currentAngle, slices: slices)
                .gesture(dragGesture)
                .readFrame(frame: $wheelFrame, coordinateSpace: .named(String.discountWheelNamespace))
            Spacer()
            Spacer()
            spinButton
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorPalette.backgroundColor)
        .coordinateSpace(name: .discountWheelNamespace)
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

    // MARK: - Spinning

    @State private var wheelFrame: CGRect = .zero
    @State private var previousDraggingAngle: Angle = .zero

    var wheelCenterPoint: CGPoint {
        CGPoint(
            x: wheelFrame.origin.x + wheelFrame.width / 2,
            y: wheelFrame.origin.y + wheelFrame.height / 2
        )
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
                previousDraggingAngle = currentDraggingAngle
            }
            .onEnded { _ in
                previousDraggingAngle = .zero
                withAnimation(.timingCurve(0.2, 0.8, 0.05, 1.0, duration: 10)) {
                    currentAngle.onDragRelease()
                }
            }
    }

    // MARK: -

    private var spinButton: some View {
        AsyncButton {
            withAnimation(.timingCurve(0.2, 0.8, 0.05, 1.0, duration: 10)) {
                currentAngle = .degrees(-1805)
            }
            try? await Task.sleep(for: .seconds(10))
            throwConfetti = 1
            try? await Task.sleep(for: .milliseconds(500))
            throwConfetti += 1
            try? await Task.sleep(for: .milliseconds(500))
            throwConfetti += 1
            try? await Task.sleep(for: .milliseconds(500))
            showSuccessAlert = true
        } label: {
            Text(step.spinButtonTitle)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(currentAngle != .initialAngle)
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

    mutating func applyDelta(_ delta: Angle) {
        if delta.degrees > 180 {
            self += delta - .degrees(360)
        } else if delta.degrees < -180 {
            self += delta + .degrees(360)
        } else {
            self += delta
        }
    }

    mutating func onDragRelease() {
        let isClockwise = self - Self.initialAngle > .degrees(0)
        self = .degrees(isClockwise ? -1805 : 1760)
    }
}

private extension Hashable where Self == String {

    static var discountWheelNamespace: Self {
        "DiscountWheel.Namespace"
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

#Preview {
    DiscountWheelStepView(step: .testData())
}
