#if !os(Android)
//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import SwiftUI

struct TimePickerStepView: View {

    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    var step: TimePickerStep

    var body: some View {
        WheelTimePicker(step: localizedStep) { time in
            var answer = step.answer
            answer.payload = .string(time)
            await viewModel.onAnswer(answers: [answer])
        }
    }

    private var localizedStep: TimePickerStep {
        var answer = step.answer
        answer.title = viewModel.localize(step.answer.title)
        return TimePickerStep(title: viewModel.localize(step.title), answer: answer)
    }
}

#Preview {
    TimePickerStepView(step: .testData())
}
#endif
