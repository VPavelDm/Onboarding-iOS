//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 26.09.24.
//

import SwiftUI

private struct DiscountWheelSpinSensoryFeedback: ViewModifier, Animatable {

    var sliceAngle: Angle
    var currentAngle: Angle

    init(currentAngle: Angle, slicesCount: Int) {
        self.sliceAngle = Angle.degrees(360.0 / Double(slicesCount))
        self.currentAngle = currentAngle
    }

    var animatableData: Double {
        get { currentAngle.degrees }
        set {
            currentAngle = Angle.degrees(newValue)
            print(Int(animatableData / sliceAngle.degrees))
        }
    }

    func body(content: Content) -> some View {
        content
            .sensoryFeedback(feedbackType: .alignment, trigger: Int(animatableData / sliceAngle.degrees))
    }
}

extension View {

    func wheelSpinSensoryFeedback(currentAngle: Angle, slicesCount: Int) -> some View {
        modifier(DiscountWheelSpinSensoryFeedback(currentAngle: currentAngle, slicesCount: slicesCount))
    }
}

#Preview {
    DiscountWheelStepView(step: .testData())
}
