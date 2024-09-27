//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 26.09.24.
//

import SwiftUI

private struct DiscountWheelSpinSensoryFeedback: ViewModifier, Animatable {

    @Binding var currentAngle: Angle
    var slicesCount: Int

    var animatableData: Int {
        get {
            let sliceAngle = Angle.degrees(360.0 / Double(slicesCount))
            return Int(currentAngle.degrees / sliceAngle.degrees)
        }
        set {
            let sliceAngle = Angle.degrees(360.0 / Double(slicesCount))
            currentAngle = Angle.degrees(Double(newValue) * sliceAngle.degrees)
        }
    }

    func body(content: Content) -> some View {
        content
            .sensoryFeedback(feedbackType: .alignment, trigger: animatableData)
    }
}

extension View {

    func wheelSpinSensoryFeedback(currentAngle: Binding<Angle>, slicesCount: Int) -> some View {
        modifier(DiscountWheelSpinSensoryFeedback(currentAngle: currentAngle, slicesCount: slicesCount))
    }
}
