//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import SwiftUI
import CoreUI

struct ProgressBarView: View {

    @State private var size: CGSize = .zero

    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(viewModel.colorPalette.progressBarBackgroundColor)
                .clipShape(ProgressBarShape(isCompleted: true))
            Rectangle()
                .fill(viewModel.colorPalette.accentColor)
                .frame(width: size.width * viewModel.passedStepsProcent)
                .clipShape(ProgressBarShape(isCompleted: viewModel.passedStepsProcent == 1))
                .animation(.spring(duration: 0.35, bounce: 0.35), value: viewModel.passedStepsProcent)
        }
        .frame(height: .size)
        .readSize(size: $size)
    }
}

// MARK: - Constants

private extension CGFloat {

    static let size: Self = 8
}

#Preview {
    OnboardingView(
        configuration: .testData(),
        delegate: MockOnboardingDelegate(),
        colorPalette: .testData,
        outerScreen: { _, _ in Text("Hello") }
    )
    .preferredColorScheme(.dark)
}
