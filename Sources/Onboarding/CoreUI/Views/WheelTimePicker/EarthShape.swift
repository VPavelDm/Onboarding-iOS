//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 19.09.24.
//

import SwiftUI

@available(iOS 17.0, *)
extension WheelTimePicker {

    struct EarthShape: Shape {

        func path(in rect: CGRect) -> Path {
            var path = Path()

            let height: CGFloat = rect.height * 0.15

            path.move(to: CGPoint(x: rect.minX, y: height))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: height),
                control: CGPoint(x: rect.midX, y: -height)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()

            return path
        }
    }
}
