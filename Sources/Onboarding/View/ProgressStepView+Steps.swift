//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 18.09.24.
//

import SwiftUI

extension ProgressStepView {

    var stepsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(step.steps.indices, id: \.self) { index in
                HStack(spacing: 12) {
                    checkmarkView(at: index)
                    stepView(at: index)
                }
                .animation(.easeInOut, value: stepCompleted(at: index))
            }
        }
    }

    private func checkmarkView(at index: Int) -> some View {
        Image(systemName: "checkmark")
            .resizable()
            .font(.system(size: 128, weight: .bold))
            .frame(width: 12, height: 12)
            .foregroundStyle(colorPalette.backgroundColor)
            .padding(8)
            .background {
                if stepCompleted(at: index) {
                    Circle()
                        .fill(colorPalette.progressBarColor)
                } else {
                    Circle()
                        .stroke(lineWidth: 1)
                        .fill(colorPalette.progressBarDisabledColor)
                }
            }
    }

    private func stepView(at index: Int) -> some View {
        Text(step.steps[index])
            .font(.system(size: 20))
            .foregroundStyle(stepCompleted(at: index) ? colorPalette.primaryTextColor : colorPalette.progressBarDisabledColor)
    }

    private func stepCompleted(at index: Int) -> Bool {
        CGFloat(index + 1) / CGFloat(step.steps.count) * 100 <= progress
    }
}
