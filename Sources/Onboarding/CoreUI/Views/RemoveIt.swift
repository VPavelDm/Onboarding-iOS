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
    @Binding var isAnimating: Bool

    var color1: Color {
        true ? Color(red: 13/255, green: 13/255, blue: 13/255) : Color(red: 5/255, green: 5/255, blue: 5/255)
    }
    var color2: Color {
        true ? Color(red: 26/255, green: 26/255, blue: 46/255) : Color(red: 12/255, green: 12/255, blue: 22/255)
    }
    var color3: Color {
        true ? Color(red: 44/255, green: 44/255, blue: 84/255) : Color(red: 20/255, green: 20/255, blue: 40/255)
    }
    var color4: Color {
        true ? Color(red: 58/255, green: 12/255, blue: 163/255) : Color(red: 25/255, green: 5/255, blue: 90/255)
    }
    var color5: Color {
        true ? Color(red: 78/255, green: 42/255, blue: 132/255) : Color(red: 35/255, green: 20/255, blue: 65/255)
    }
    var color6: Color {
        true ? Color(red: 45/255, green: 49/255, blue: 66/255) : Color(red: 20/255, green: 22/255, blue: 30/255)
    }
    var color7: Color {
        true ? Color(red: 34/255, green: 34/255, blue: 59/255) : Color(red: 15/255, green: 15/255, blue: 28/255)
    }
    var color8: Color {
        true ? Color(red: 27/255, green: 27/255, blue: 47/255) : Color(red: 12/255, green: 12/255, blue: 22/255)
    }
    var color9: Color {
        true ? Color(red: 47/255, green: 47/255, blue: 47/255) : Color(red: 18/255, green: 18/255, blue: 18/255)
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
        .animation(.easeInOut(duration: 3), value: isAnimating)
        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isActive)
        .onAppear {
            isActive = true
        }
    }
}

#Preview {
    MockOnboardingView()
}
