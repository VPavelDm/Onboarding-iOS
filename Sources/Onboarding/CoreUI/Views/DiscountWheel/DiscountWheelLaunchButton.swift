//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 02.11.24.
//

import SwiftUI

struct DiscountWheelLaunchButton: View {
    @Environment(\.colorPalette) private var colorPalette

    @State private var scaleFactor: CGFloat = 1
    @State private var pressedAt: Date?

    @Binding var progress: CGFloat
    @Binding var pressed: Bool

    var body: some View {
        Text("🔥 Power Up")
            .foregroundStyle(colorPalette.primaryButtonTextColor)
            .font(.system(size: 16, weight: .semibold))
            .padding()
            .background(colorPalette.secondaryButtonBackgroundColor)
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
    }

    private func onPressing() {
        pressedAt = Date()
        withAnimation(.linear(duration: .maxPressDuration)) {
            pressed = true
            scaleFactor = 0.9
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

struct MyProgressBarView: View {
    @State private var screenSize: CGSize = .zero

    @Binding var pressed: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .frame(height: 5)
                .foregroundStyle(.red)
            Rectangle()
                .frame(width: pressed ? screenSize.width : 0, height: 5)
                .foregroundStyle(.blue)
        }
        .readSize(size: $screenSize)
    }
}

private extension TimeInterval {

    static let maxPressDuration: CGFloat = 10
}

#Preview {
    DiscountWheelStepView(step: .testData())
}
