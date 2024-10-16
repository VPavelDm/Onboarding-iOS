//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 26.09.24.
//

import SwiftUI

enum SensoryFeedbackType: String, Identifiable, CaseIterable, Equatable, Hashable {
    var id: Self { self }
    
    case success
    case alignment
    case warning
    case error
    case selection
    case increase
    case decrease
    case start
    case stop
    case levelChange


    @available(iOS 17.0, *)
    var sensoryFeedback: SensoryFeedback {
        switch self {
        case .success:
                .success
        case .alignment:
                .levelChange
        case .warning:
                .warning
        case .error:
                .error
        case .selection:
                .selection
        case .increase:
                .increase
        case .decrease:
                .decrease
        case .start:
                .start
        case .stop:
                .stop
        case .levelChange:
                .levelChange
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
