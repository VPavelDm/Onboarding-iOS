//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 26.09.24.
//

import SwiftUI

private struct DiscountWheelSpinSensoryFeedback: ViewModifier, Animatable {

    var sliceAngle: Angle
    @Binding var currentAngle: Angle

    init(currentAngle: Binding<Angle>, slicesCount: Int) {
        self.sliceAngle = Angle.degrees(360.0 / Double(slicesCount))
        self._currentAngle = currentAngle
    }

    var animatableData: Double {
        get { currentAngle.degrees }
        set {
            currentAngle = Angle.degrees(newValue)
            print(Int(newValue / sliceAngle.degrees))
        }
    }

    func body(content: Content) -> some View {
        content
            .sensoryFeedback(feedbackType: .alignment, trigger: Int(animatableData / sliceAngle.degrees))
    }
}

extension View {

    func wheelSpinSensoryFeedback(currentAngle: Binding<Angle>, slicesCount: Int) -> some View {
        modifier(DiscountWheelSpinSensoryFeedback(currentAngle: currentAngle, slicesCount: slicesCount))
    }
}

#Preview {
    DiscountWheelStepView(step: .testData())
}
