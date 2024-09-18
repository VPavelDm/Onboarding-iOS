//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 18.09.24.
//

import SwiftUI

struct ProgressCircleView: View {
    @Environment(\.colorPalette) private var colorPalette

    @State private var circleProgress: CGFloat = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let duration: TimeInterval
    @Binding var progress: CGFloat

    var body: some View {
        progressView
            .onReceive(timer) { _ in
                circleProgress = 1
                if progress < 100 {
                    progress = min(progress + 100 / duration, 100)
                } else {
                    progress = 100
                    timer.upstream.connect().cancel()
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
            .stroke(colorPalette.progressBarBackgroundColor, lineWidth: 12)
    }

    private var progressCircle: some View {
        Circle()
            .trim(from: 0, to: circleProgress)
            .stroke(
                colorPalette.progressBarColor,
                style: StrokeStyle(lineWidth: 12, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .animation(.linear(duration: duration), value: circleProgress)
    }

    private var progressText: some View {
        Text("\(Int(progress)) %")
            .monospacedDigit()
            .foregroundStyle(colorPalette.primaryTextColor)
            .font(.system(size: 32, weight: .bold))
            .contentTransition(.numericText())
            .animation(.linear, value: progress)
    }
}

#Preview {
    ProgressCircleView(duration: 15, progress: .constant(50))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.testData.backgroundColor)
}
