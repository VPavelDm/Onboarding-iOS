//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import SwiftUI

struct BottomWaveShape: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: .zero)
        path.addLine(to: .init(x: rect.maxX, y: rect.minY))
        path.addLine(to: .init(x: rect.maxX, y: rect.maxY * 0.85))
        path.addQuadCurve(
            to: .init(x: rect.minX, y: rect.maxY * 0.85),
            control: .init(x: rect.midX * 0.75, y: rect.maxY)
        )
        path.closeSubpath()

        return path
    }
}
