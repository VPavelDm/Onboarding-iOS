//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 23.09.24.
//

import SwiftUI

struct CasinoWheel: View {

    @State private var currentAngle: Angle

    var colors: [Color]

    init(colors: [Color]) {
        self._currentAngle = State(initialValue: .initialAngle(count: colors.count))
        self.colors = colors
    }

    var body: some View {
        ZStack(alignment: .top) {
            ZStack {
                slicesView
                centerCircle
                borderCircle
            }
            .rotationEffect(currentAngle)
            .padding(.top, .borderCircleHeight * 2.5)
            .onTapGesture {
                withAnimation(.timingCurve(0.2, 0.8, 0.2, 1.0, duration: 5)) {
                    currentAngle = .degrees(720)
                }
            }
            pointerView
        }
        .aspectRatio(1.0, contentMode: .fit)
    }

    private var slicesView: some View {
        ForEach(colors.indices, id: \.self) { index in
            CasinoWheelSlice(
                startAngle: .sliceStartAngle(at: index, count: colors.count),
                endAngle: .sliceEndAngle(at: index, count: colors.count)
            )
            .fill(colors[index])
        }
    }

    private var centerCircle: some View {
        Circle()
            .fill(colors[0])
            .frame(width: 16, height: 16)
    }

    private var borderCircle: some View {
        Circle()
            .strokeBorder(Color.white.opacity(0.5), lineWidth: .borderCircleHeight)
    }

    private var pointerView: some View {
        ZStack(alignment: .top) {
            CasinoWheelPointer()
                .fill(Color.white)
                .frame(
                    width: .pointerWidth,
                    height: .pointerWidth * 2
                )
            Circle()
                .fill(ColorPalette.testData.backgroundColor)
                .frame(
                    width: .pointerInnerCircleRadius * 2,
                    height: .pointerInnerCircleRadius * 2
                )
                .padding(.top, (.pointerWidth / 2 - .pointerInnerCircleRadius))
        }
    }
}

private extension Angle {

    static func sliceStartAngle(at index: Int, count: Int) -> Angle {
        .degrees(Double(index) * 360 / Double(count))
    }

    static func sliceEndAngle(at index: Int, count: Int) -> Angle {
        sliceStartAngle(at: index, count: count) + .degrees(360 / Double(count))
    }

    static func initialAngle(count: Int) -> Angle {
        .degrees(360 / Double(count)) / 2
    }
}

private extension CGFloat {

    static var borderCircleHeight: CGFloat = 8

    static var pointerWidth: CGFloat = 30
    static var pointerInnerCircleRadius: CGFloat = 4

}

#Preview {
    CasinoStepView()
}
