//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 09.09.24.
//

import SwiftUI

extension WelcomeView {

    struct AnimatedImageView: View {
        @Environment(\.colorPalette) private var colorPalette

        let step: WelcomeStep

        var innitOrbitEmojis: [String] {
            Array(step.emojis[0..<(step.emojis.count / 2)])
        }

        var outerOrbitEmojis: [String] {
            Array(step.emojis[(step.emojis.count / 2)...])
        }

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    WelcomeView.OrbitView(
                        emojis: innitOrbitEmojis,
                        radius: geometry.size.width / 2 * 0.85,
                        progressOffset: .zero
                    )
                    WelcomeView.OrbitView(
                        emojis: outerOrbitEmojis,
                        radius: geometry.size.width / 2 * 1.15,
                        progressOffset: 0.5
                    )
                    VStack {
                        titleView
                        descriptionView
                    }
                    .frame(maxWidth: geometry.size.width * 0.75)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }

        private var titleView: some View {
            Text(step.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(colorPalette.primaryTextColor)
        }

        private var descriptionView: some View {
            Text(step.description)
                .font(.body)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundStyle(colorPalette.secondaryTextColor)
        }
    }
}

#Preview {
    OnboardingView(
        configuration: .testData(),
        delegate: MockOnboardingDelegate(),
        outerScreen: { _ in Text("") }
    )
}
