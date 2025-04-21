//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 29.03.25.
//

import SwiftUI

struct NameStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var name: String = ""

    var step: EnterNameStep

    var body: some View {
        VStack(alignment: .leading, spacing: .contentSpacing) {
            VStack(alignment: .leading, spacing: .headingSpacing) {
                titleView
                descriptionView
            }
            nameInputView
            Spacer()
            nextButton
        }
        .padding(.vertical, .vScreenPadding)
        .padding(.horizontal, .hScreenPadding)
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.leading)
    }

    private var descriptionView: some View {
        Text(step.description)
            .font(.title3)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
            .multilineTextAlignment(.leading)
    }

    private var nameInputView: some View {
        TextField("Enter your name", text: $name)
            .textFieldStyle(NameTextFieldStyle(colorPalette: viewModel.colorPalette))
            .textContentType(.name)
            .keyboardType(.namePhonePad)
            .submitLabel(.continue)
            .textInputAutocapitalization(.words)
            .onSubmit {
                Task {
                    await viewModel.onAnswer(answers: [step.answer])
                }
            }
    }

    private var nextButton: some View {
        AsyncButton {
            var step = step
            step.answer.payload = .string(name)
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(name.isEmpty)
        .animation(.easeInOut, value: name.isEmpty)
    }
}

private struct NameTextFieldStyle: TextFieldStyle {
    var colorPalette: any ColorPalette

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundStyle(colorPalette.secondaryButtonForegroundColor)
            .padding()
            .background(colorPalette.secondaryButtonBackgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(colorPalette.secondaryButtonStrokeColor, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    MockOnboardingView()
}
