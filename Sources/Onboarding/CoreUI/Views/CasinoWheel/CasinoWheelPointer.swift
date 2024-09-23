//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 23.09.24.
//

import SwiftUI

struct CasinoWheelPointer: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let topCircleRadius = rect.midX
        let bottomCircleRadius = rect.width / 6

        let topCircleCenter = CGPoint(x: rect.midX, y: rect.midX)

        let topCircleLeftY = rect.midX

        let bottomCircleLeftX = rect.midX - bottomCircleRadius
        let bottomCircleLeftY = rect.maxY - bottomCircleRadius

        path.move(to: topCircleCenter)
        path.addArc(
            center: topCircleCenter,
            radius: topCircleRadius,
            startAngle: .zero,
            endAngle: .degrees(180),
            clockwise: true
        )

        path.addLine(to: .init(x: bottomCircleLeftX, y: bottomCircleLeftY))

        let control1 = CGPoint(
            x: (rect.maxY - topCircleLeftY) / (bottomCircleLeftY - topCircleLeftY) * (rect.midX - bottomCircleRadius),
            y: rect.maxY
        )
        let control2 = CGPoint(
            x: rect.midX + (rect.midX - control1.x),
            y: rect.maxY
        )
        path.addCurve(
            to: .init(x: rect.midX + bottomCircleRadius, y: rect.maxY - bottomCircleRadius),
            control1: control1,
            control2: control2
        )

        path.addLine(to: .init(x: rect.maxX, y: topCircleRadius))

        path.closeSubpath()

        return path
    }
}

#Preview {
    CasinoWheelPointer()
        .fill(Color.red)
        .padding()
}
