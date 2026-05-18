//
//  MeshGradientBackground.swift
//  onboarding-ios
//

import SwiftUI

struct MeshGradientBackground: View {

    var body: some View {
        if #available(iOS 18.0, *) {
            AnimatedMeshGradient()
        } else {
            Color.black
        }
    }
}

@available(iOS 18.0, *)
private struct AnimatedMeshGradient: View {
    @State private var isActive: Bool = false

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSince1970
            let offset = Float(sin(t)) / 4
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [0.5 + offset, 0.5 - offset], [1, 0.5 - offset],
                    [0, 1], [0.5 - offset, 1], [1, 1],
                ],
                colors: [
                    .black, Color(.systemGray6), isActive ? Color(red: 0.3, green: 0.25, blue: 0.0) : .black,
                    Color(.systemGray6), Color(red: 0.25, green: 0.2, blue: 0.0), .black,
                    isActive ? Color(red: 0.25, green: 0.2, blue: 0.0) : .black, Color(.systemGray6), .black,
                ]
            )
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isActive = true
            }
        }
    }
}
