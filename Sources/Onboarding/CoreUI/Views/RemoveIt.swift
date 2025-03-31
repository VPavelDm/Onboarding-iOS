//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 30.03.25.
//

import SwiftUI

@available(iOS 18.0, *)
public struct AffirmationBackgroundView: View {
    @State private var isActive: Bool = true

    var color1: Color {
        Color(red: 13/255, green: 13/255, blue: 13/255)
    }
    var color2: Color {
        Color(red: 26/255, green: 26/255, blue: 46/255)
    }
    var color3: Color {
        Color(red: 44/255, green: 44/255, blue: 84/255)
    }
    var color4: Color {
        Color(red: 58/255, green: 12/255, blue: 163/255)
    }
    var color5: Color {
        Color(red: 78/255, green: 42/255, blue: 132/255)
    }
    var color6: Color {
        Color(red: 45/255, green: 49/255, blue: 66/255)
    }
    var color7: Color {
        Color(red: 34/255, green: 34/255, blue: 59/255)
    }
    var color8: Color {
        Color(red: 27/255, green: 27/255, blue: 47/255)
    }
    var color9: Color {
        Color(red: 47/255, green: 47/255, blue: 47/255)
    }

    public var body: some View {
        TimelineView(.animation) { context in
            let epochTime = context.date.timeIntervalSince1970
            let offset = Float(sin(epochTime)) / 4
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [0.5 + offset, 0.5 - offset], [1, 0.5 - offset],
                    [0, 1], [0.5 - offset, 1], [1, 1],
                ],
                colors: [
                    color1, color2, isActive ? color9 : color3,
                    color4, color5, color6,
                    isActive ? color5 : color7, color8, color9,
                ]
            )
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isActive)
        .onAppear {
            isActive = true
        }
    }
}

#Preview {
    MockOnboardingView()
}
