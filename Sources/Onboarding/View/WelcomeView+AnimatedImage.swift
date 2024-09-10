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

        let emojis: [String] = ["🦥", "⚽️", "🧩", "✈️", "🏖️", "🏔️"]

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    WelcomeView.OrbitView(
                        emojis: Array(emojis[0...2]),
                        radius: geometry.size.width / 2 * 0.85,
                        progressOffset: .zero
                    )
                    WelcomeView.OrbitView(
                        emojis: Array(emojis[3...]),
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
            Text("Welcome to Lyncil")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(colorPalette.primaryTextColor)
        }

        private var descriptionView: some View {
            Text("Unleash Your Songwriting Potential with Lyncil")
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
        outerScreen: { _ in Text("") },
        completion: { _ in }
    )
}
