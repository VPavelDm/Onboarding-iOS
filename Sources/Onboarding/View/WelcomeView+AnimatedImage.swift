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

        @State private var availableSize: CGSize = .zero

        let emojis: [String] = ["🦥", "⚽️", "🧩", "✈️", "🏖️", "🏔️"]

        var firstRadius: CGFloat {
            let circleSize = min(availableSize.width, availableSize.height) / 2
            return circleSize
        }

        var secondRadius: CGFloat {
            let circleSize = min(availableSize.width, availableSize.height) / 2
            return circleSize * 1.15
        }

        var body: some View {
            ZStack {
                WelcomeView.OrbitView(emojis: Array(emojis[0...2]), radius: firstRadius, progressOffset: .zero)
                WelcomeView.OrbitView(emojis: Array(emojis[3...]), radius: secondRadius, progressOffset: 0.5)
                VStack {
                    titleView
                    descriptionView
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .readSize(size: $availableSize)
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
