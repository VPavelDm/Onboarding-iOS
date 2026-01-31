//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 18.09.24.
//

import SwiftUI

extension ProgressStepView {

    var stepsView: some View {
        VStack(alignment: .leading, spacing: .buttonsSpacing) {
            ForEach(step.steps.indices, id: \.self) { index in
                HStack(spacing: 12) {
                    checkmarkView(at: index)
                    stepView(at: index)
                }
                .animation(.easeInOut, value: stepCompleted(at: index))
            }
        }
    }

    @ViewBuilder
    private func checkmarkView(at index: Int) -> some View {
        if stepCompleted(at: index) {
            ZStack {
                Circle()
                    .fill(viewModel.colorPalette.primaryButtonBackgroundColor)
                Image(systemName: "checkmark")
                    .fontWeight(.semibold)
                    .blendMode(.destinationOut)
            }
            .frame(width: 28, height: 28)
            .compositingGroup()
        } else {
            Circle()
                .stroke(lineWidth: 1)
                .fill(viewModel.colorPalette.secondaryTextColor)
                .frame(width: 28, height: 28)
        }
    }

    private func stepView(at index: Int) -> some View {
        Text(step.steps[index])
            .font(.system(size: 16))
            .foregroundStyle(stepCompleted(at: index) ? viewModel.colorPalette.textColor : viewModel.colorPalette.secondaryTextColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func stepCompleted(at index: Int) -> Bool {
        CGFloat(index + 1) / CGFloat(step.steps.count) * 100 <= progress
    }
}

#Preview {
    MockOnboardingView()
}
