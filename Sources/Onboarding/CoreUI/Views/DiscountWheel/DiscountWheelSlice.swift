//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 23.09.24.
//

import SwiftUI

struct DiscountWheelSlice: Shape {

    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}
