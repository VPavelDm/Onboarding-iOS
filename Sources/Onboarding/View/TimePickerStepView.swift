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
            var answer = step.answer
            answer.payload = .string(time)
            await viewModel.onAnswer(answers: [answer])
        }
    }
}

#Preview {
    TimePickerStepView(step: .testData())
}
