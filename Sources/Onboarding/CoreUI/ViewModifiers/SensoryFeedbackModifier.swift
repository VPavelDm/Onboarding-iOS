//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 26.09.24.
//

import SwiftUI

enum SensoryFeedbackType {
    case success
    case alignment

    @available(iOS 17.0, *)
    var sensoryFeedback: SensoryFeedback {
        switch self {
        case .success:
                .success
        case .alignment:
                .selection
        }
    }
}

private struct SensoryFeedbackModifier: ViewModifier {

    var feedback: SensoryFeedbackType
    var trigger: Int

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .sensoryFeedback(feedback.sensoryFeedback, trigger: trigger)
        } else {
            content
        }
    }
}

extension View {

    func sensoryFeedback(feedbackType: SensoryFeedbackType, trigger: Int) -> some View {
        modifier(SensoryFeedbackModifier(feedback: feedbackType, trigger: trigger))
    }
}
