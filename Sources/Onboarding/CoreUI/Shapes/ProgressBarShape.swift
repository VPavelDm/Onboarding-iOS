//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import SwiftUI

struct ProgressBarShape: Shape {
    var isCompleted: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: .init(x: rect.midY * 2, y: rect.minY))

        if isCompleted {
            path.addLine(to: .init(x: rect.maxX - rect.midY * 2, y: rect.minY))
            path.addCurve(
                to: .init(x: rect.maxX - rect.midY * 2, y: rect.maxY),
                control1: .init(x: rect.maxX, y: rect.minY),
                control2: .init(x: rect.maxX, y: rect.maxY)
            )
        } else {
            path.addLine(to: .init(x: rect.maxX, y: rect.minY))
            path.addLine(to: .init(x: rect.maxX - rect.midY * 2, y: rect.maxY))
        }
        path.addLine(to: .init(x: rect.midY * 2, y: rect.maxY))
        path.addCurve(
            to: .init(x: rect.midY * 2, y: rect.minY),
            control1: .init(x: rect.minX, y: rect.maxY),
            control2: .init(x: rect.minX, y: rect.minY)
        )
        path.closeSubpath()

        return path
    }
}

#Preview {
    OnboardingView(
        configuration: .testData(),
        outerScreen: { _, _ in Text("Hello") },
        completion: { _ in}
    )
}
