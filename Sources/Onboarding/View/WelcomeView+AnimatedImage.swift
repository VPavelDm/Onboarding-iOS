//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 09.09.24.
//

import SwiftUI

extension WelcomeView {

    struct AnimatedImageView: View {

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
                        radius: geometry.size.innerRadius,
                        progressOffset: .zero
                    )
                    WelcomeView.OrbitView(
                        emojis: outerOrbitEmojis,
                        radius: geometry.size.outerRadius,
                        progressOffset: 0.5
                    )
                    VStack {
                        titleView
                        descriptionView
                    }
                    .frame(maxWidth: geometry.size.maxTextWidth)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }

        private var titleView: some View {
            Text(step.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
        }

        private var descriptionView: some View {
            Text(step.description)
                .font(.body)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }
}

private extension CGSize {

    var minSide: CGFloat {
        min(width, height)
    }

    var innerRadius: CGFloat {
        if minSide < 500 {
            minSide / 2 * 0.85
        } else {
            minSide / 2 * 0.75
        }
    }

    var outerRadius: CGFloat {
        if minSide < 500 {
            minSide / 2 * 1.15
        } else {
            minSide / 2 * 0.95
        }
    }

    var maxTextWidth: CGFloat {
        if minSide < 500 {
            minSide * 0.7
        } else {
            minSide * 0.6
        }
    }
}

#Preview {
    OnboardingView(
        configuration: .testData(),
        delegate: MockOnboardingDelegate(),
        outerScreen: { _ in Text("") }
    )
    .preferredColorScheme(.dark)
}
