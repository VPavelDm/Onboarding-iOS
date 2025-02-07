//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 10.09.24.
//

import SwiftUI

extension WelcomeView {

    struct OrbitView: View {

        @EnvironmentObject private var viewModel: OnboardingViewModel

        @State private var progress: CGFloat = .zero
        var emojis: [String]
        var radius: CGFloat
        var progressOffset: CGFloat

        var body: some View {
            ZStack {
                Circle()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(viewModel.colorPalette.plainButtonColor)
                    .frame(width: radius * 2, height: radius * 2)
                ForEach(emojis.indices, id: \.self) { index in
                    EmojiOnOrbitView(
                        emoji: emojis[index],
                        progress: progress + CGFloat(index) / CGFloat(emojis.count) + progressOffset,
                        orbitRadius: radius
                    )
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    progress += 1
                }
            }
        }
    }

    private struct EmojiOnOrbitView: View, Animatable {
        var emoji: String
        var progress: CGFloat
        var orbitRadius: CGFloat

        var animatableData: CGFloat {
            get { progress }
            set { progress = newValue }
        }

        var animatableAngle: Angle {
            Angle(degrees: progress * 360.0)
        }

        var body: some View {
            Text(emoji)
                .font(.system(size: 38))
                .offset(
                    x: orbitRadius * cos(animatableAngle.radians),
                    y: orbitRadius * sin(animatableAngle.radians)
                )
        }
    }
}

#Preview {
    WelcomeView(step: .testData())
        .preferredColorScheme(.dark)
}
