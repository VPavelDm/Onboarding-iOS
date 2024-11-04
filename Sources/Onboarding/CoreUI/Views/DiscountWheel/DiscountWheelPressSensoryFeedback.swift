//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 04.11.24.
//

import SwiftUI

private struct DiscountWheelPressSensoryFeedback: ViewModifier, Animatable {

    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content
            .sensoryFeedback(feedbackType: .increase, trigger: Int(animatableData))
    }
}

extension View {

    func pressSensoryFeedback(progress: Double) -> some View {
        modifier(DiscountWheelPressSensoryFeedback(progress: progress))
    }
}

#Preview {
    DiscountWheelStepView(step: .testData())
}

