//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import SwiftUI

struct TimePickerStepView: View {

    @EnvironmentObject private var viewModel: OnboardingViewModel

    var step: TimePickerStep

    var body: some View {
        WheelTimePicker(step: step) { time in
            try? await viewModel.delegate.setupNotifications(for: time)
            await viewModel.onAnswer(answers: [step.answer])
        }
    }
}

#Preview {
    TimePickerStepView(step: .testData())
}
