//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 23.09.24.
//

import SwiftUI

struct DiscountWheel: View {

    @Environment(\.colorPalette) private var colorPalette

    @State private var wheelSize: CGSize = .zero

    @Binding var currentAngle: Angle
    var slices: [Slice]

    var body: some View {
        ZStack(alignment: .top) {
            ZStack {
                slicesView
                centerCircle
                borderCircle
            }
            .rotationEffect(currentAngle)
            .padding(.top, .borderCircleHeight * 2.5)
            pointerView
        }
        .aspectRatio(1.0, contentMode: .fit)
    }

    private var slicesView: some View {
        ZStack {
            ForEach(slices.indices, id: \.self) { index in
                DiscountWheelSlice(
                    startAngle: .sliceStartAngle(at: index, count: slices.count),
                    endAngle: .sliceEndAngle(at: index, count: slices.count)
                )
                .fill(slices[index].color)
                giftView(at: index)
            }
        }
        .readSize(size: $wheelSize)
    }

    private func giftView(at index: Int) -> some View {
        Text("\(slices[index].value)%")
            .foregroundStyle(colorPalette.primaryTextColor)
            .font(.system(size: 26, weight: .bold))
            .rotationEffect(.textRotationAngle(at: index, count: slices.count))
            .offset(.textOffset(at: index, count: slices.count, in: wheelSize))
            .zIndex(1)
    }

    private var centerCircle: some View {
        Circle()
            .fill(slices[0].color)
            .frame(width: 16, height: 16)
    }

    private var borderCircle: some View {
        Circle()
            .strokeBorder(Color.white.opacity(0.5), lineWidth: .borderCircleHeight)
    }

    private var pointerView: some View {
        ZStack(alignment: .top) {
            DiscountWheelPointer()
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

    struct Slice: Identifiable, Sendable, Equatable {
        var id: UUID = UUID()
        var value: String
        var color: Color
    }
}

private extension Angle {

    static func sliceStartAngle(at index: Int, count: Int) -> Angle {
        .degrees(Double(index) * 360 / Double(count))
    }

    static func sliceEndAngle(at index: Int, count: Int) -> Angle {
        sliceStartAngle(at: index, count: count) + .degrees(360 / Double(count))
    }

    static func sliceMiddleAngle(at index: Int, count: Int) -> Angle {
        let startAngle = Angle.sliceStartAngle(at: index, count: count)
        let endAngle = Angle.sliceEndAngle(at: index, count: count)
        return (startAngle + endAngle) / 2
    }

    static func textRotationAngle(at index: Int, count: Int) -> Angle {
        let initialAngle = Angle.degrees(360) / Double(count) / 2 + Angle.degrees(90)

        return initialAngle + Angle.degrees(Double(index) * 360 / Double(count))
    }
}

private extension CGSize {

    static func textOffset(at index: Int, count: Int, in size: CGSize) -> CGSize {
        let radius = size.width / 3.5

        let angle = Angle.sliceMiddleAngle(at: index, count: count)

        let textCenterX: CGFloat = cos(angle.radians) * radius
        let textCenterY = sin(angle.radians) * radius

        return CGSize(
            width: textCenterX,
            height: textCenterY
        )
    }
}

private extension CGFloat {

    static var borderCircleHeight: CGFloat = 8

    static var pointerWidth: CGFloat = 30
    static var pointerInnerCircleRadius: CGFloat = 4

}

#Preview {
    DiscountWheelStepView()
}
