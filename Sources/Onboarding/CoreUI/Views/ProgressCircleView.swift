//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 18.09.24.
//

import SwiftUI

struct ProgressCircleView: View {

    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State var circleProgress: CGFloat = .zero

    let duration: TimeInterval
    @Binding var progress: CGFloat
    var finished: Bool

    var body: some View {
        progressView
            // `.task`-based tick instead of a Combine `Timer`/`onReceive` (unavailable in Skip).
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(1))
                    if progress < 93 {
                        progress = min(progress + 100 / duration, 100)
                    } else if finished {
                        progress = 100
                        circleProgress = progress / 100
                        break
                    } else {
                        progress = 93
                    }
                    circleProgress = progress / 100
                }
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
            .stroke(viewModel.colorPalette.progressBarBackgroundColor, lineWidth: 12)
    }

    private var progressCircle: some View {
        Circle()
            .trim(from: 0, to: circleProgress)
            .stroke(
                viewModel.colorPalette.primaryButtonBackground,
                style: StrokeStyle(lineWidth: 12, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .animation(.linear(duration: 1), value: circleProgress)
    }

    private var progressText: some View {
        Text("\(Int(progress)) %")
            .monospacedDigitCompat()
            .foregroundStyle(viewModel.colorPalette.textColor)
            .font(.system(size: 32, weight: .bold))
            .numericContentTransitionCompat()
            .animation(.linear, value: progress)
    }
}

#if !os(Android)
#Preview {
    MockOnboardingView()
}
#endif
