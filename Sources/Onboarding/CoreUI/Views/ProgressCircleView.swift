//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 18.09.24.
//

import SwiftUI

struct ProgressCircleView: View {

    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var circleProgress: CGFloat = .zero

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let duration: TimeInterval
    @Binding var progress: CGFloat
    var finished: Bool

    var body: some View {
        progressView
            .onReceive(timer) { _ in
                if progress < 93 {
                    progress = min(progress + 100 / duration, 100)
                } else if finished {
                    progress = 100
                    timer.upstream.connect().cancel()
                } else {
                    progress = 93
                }
                circleProgress = progress / 100
            }
    }

    private var progressView: some View {
        ZStack {
            backgroundCircle
            progressCircle
            progressText
        }
        .frame(width: 200, height: 200)
    }

    private var backgroundCircle: some View {
        Circle()
            .stroke(viewModel.colorPalette.secondaryButtonBackgroundColor, lineWidth: 12)
    }

    private var progressCircle: some View {
        Circle()
            .trim(from: 0, to: circleProgress)
            .stroke(
                viewModel.colorPalette.primaryButtonBackgroundColor,
                style: StrokeStyle(lineWidth: 12, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .animation(.linear(duration: 1), value: circleProgress)
    }

    private var progressText: some View {
        Text("\(Int(progress)) %")
            .monospacedDigit()
            .foregroundStyle(viewModel.colorPalette.textColor)
            .font(.system(size: 32, weight: .bold))
            .contentTransition(.numericText())
            .animation(.linear, value: progress)
    }
}
