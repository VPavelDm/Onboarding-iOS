//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 26.09.24.
//

import SwiftUI

private struct DiscountWheelSpinSensoryFeedback: ViewModifier, Animatable {

    var currentAngle: Angle
    var slicesCount: Int

    var animatableData: Angle {
        get {
            currentAngle
        }
        set {
            currentAngle = newValue
        }
    }

    var opacity: CGFloat {
        min(abs(animatableData.degrees / -1840), 1)
    }

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
//            .sensoryFeedback(feedbackType: .alignment, trigger: animatableData)
    }
}

extension View {

    func wheelSpinSensoryFeedback(currentAngle: Angle, slicesCount: Int) -> some View {
        modifier(DiscountWheelSpinSensoryFeedback(currentAngle: currentAngle, slicesCount: slicesCount))
    }
}
