//
//  AgePickerStepView.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.01.26.
//

import SwiftUI
import CoreUI

struct AgePickerStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var age: Int = 25

    var step: AgePickerStep

    var body: some View {
        VStack(spacing: .contentSpacing) {
            VStack(spacing: .headingSpacing) {
                titleView
                descriptionView
            }
            Spacer()
            agePicker
            Spacer()
            continueButton
        }
        .padding(.vertical, .vScreenPadding)
        .padding(.horizontal, .hScreenPadding)
    }

    private var titleView: some View {
        Text(step.title)
            .multilineTextAlignment(.center)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .padding(.horizontal, .titlePadding)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
        }
    }

    private var agePicker: some View {
        Picker("Age", selection: $age) {
            ForEach(4...100, id: \.self) { year in
                Text("\(year) \(step.unit)")
                    .foregroundStyle(viewModel.colorPalette.textColor)
                    .tag(year)
            }
        }
        .pickerStyle(.wheel)
        .frame(height: 200)
    }

    private var continueButton: some View {
        AsyncButton {
            await onContinue()
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    private func onContinue() async {
        var answer = step.answer
        answer.payload = .string("\(age)")
        await viewModel.onAnswer(answers: [answer])
    }
}

// MARK: - Preview

#Preview {
    MockOnboardingView()
}
