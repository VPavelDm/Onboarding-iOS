//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import SwiftUI
import CoreUI

struct ProgressBarView: View {
    @Environment(\.colorPalette) private var colorPalette

    @State private var size: CGSize = .zero

    var completed: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(colorPalette.progressBarBackgroundColor)
                .clipShape(ProgressBarShape(isCompleted: true))
            Rectangle()
                .fill(colorPalette.progressBarColor)
                .frame(width: size.width * completed)
                .clipShape(ProgressBarShape(isCompleted: completed == 1))
                .animation(.spring(duration: 0.35, bounce: 0.35), value: completed)
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
        outerScreen: { _, _ in Text("Hello") },
        completion: { _ in}
    )
}
