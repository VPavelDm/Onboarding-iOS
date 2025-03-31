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
        VStack(spacing: 26) {
            VStack(spacing: 16) {
                titleView
                descriptionView
            }
            nameInputView
            Spacer()
            nextButton
        }
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    private var descriptionView: some View {
        Text(step.description)
            .font(.title3)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
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
            .padding()
    }

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(name.isEmpty)
        .animation(.easeInOut, value: name.isEmpty)
        .padding([.horizontal, .bottom])
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
