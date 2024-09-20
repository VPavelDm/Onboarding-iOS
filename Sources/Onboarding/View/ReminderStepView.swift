//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import SwiftUI

struct ReminderStepView: View {

    @EnvironmentObject private var viewModel: OnboardingViewModel

    var body: some View {
        WheelTimePicker { time in
            try? await viewModel.delegate.requestNotificationsPermission()
            await viewModel.onAnswer(answers: [])
        }
    }
}

#Preview {
    ReminderStepView()
}
