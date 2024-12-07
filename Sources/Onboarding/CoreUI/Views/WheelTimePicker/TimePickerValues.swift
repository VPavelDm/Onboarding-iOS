//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 07.12.24.
//

import SwiftUI

@available(iOS 17.0, *)
struct TimePickerValues {

    func offset(_ proxy: GeometryProxy) -> CGFloat {
        let progress = progress(proxy)
        return progress * -.progressStep
    }

    func scale(_ proxy: GeometryProxy) -> CGFloat {
        let progress = progress(proxy)
        return 1 + progress * 0.2
    }

    func opacity(_ proxy: GeometryProxy) -> CGFloat {
        progress(proxy)
    }

    func timeViewSize(in size: CGSize) -> CGFloat {
        size.width / CGFloat(timeViewBubbleCount(in: size))
    }

    func timeViewBubbleSize(in size: CGSize) -> CGFloat {
        max(timeViewSize(in: size) - timeViewBubblePadding(in: size), 0)
    }

    func hiddenBubbles(in size: CGSize) -> [Int] {
        (0..<Int(timeViewBubbleCount(in: size)/2)).map { $0 }
    }

    // MARK: - Utils

    private func progress(_ proxy: GeometryProxy) -> CGFloat {
        let screenWidth = proxy.bounds(of: .scrollView)?.width ?? .zero
        let midX = proxy.frame(in: .scrollView).midX
        return 1 - abs(midX - screenWidth / 2) / screenWidth * 2
    }

    private func timeViewBubblePadding(in size: CGSize) -> CGFloat {
        calculateY(y1: 16, y2: 26, x1: 375, x2: 1376, in: size)
    }

    private func timeViewBubbleCount(in size: CGSize) -> Int {
        let count = Int(calculateY(y1: 5, y2: 13, x1: 375, x2: 1376, in: size))
        return max(count % 2 == 0 ? count + 1 : count, 5)
    }

    private func calculateY(y1: CGFloat, y2: CGFloat, x1: CGFloat, x2: CGFloat, in size: CGSize) -> CGFloat {
        let a: CGFloat = (y2 - y1) / (x2 - x1)
        let b: CGFloat = y1 - a * x1

        return a * size.width + b
    }
}

#Preview {
    WheelTimePicker(step: .testData(), completion: { _ in })
}
